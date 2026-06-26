-- Sprint 5.1: Realtime avistamientos, ubicación editable, resumen emisor

ALTER PUBLICATION supabase_realtime ADD TABLE public.reacciones_avistamientos;

ALTER TABLE public.alertas_desaparecidos
  ADD COLUMN IF NOT EXISTS ultima_vista_texto TEXT;

DROP VIEW IF EXISTS public.v_alertas_activas;

CREATE VIEW public.v_alertas_activas
WITH (security_invoker = true) AS
SELECT
  id,
  emisor_id,
  nombre_persona,
  edad_aprox,
  vestimenta,
  ultima_vista_texto,
  foto_url,
  radio_km,
  estado,
  creado_en,
  ST_Y(ubicacion_origen::geometry) AS lat,
  ST_X(ubicacion_origen::geometry) AS lng
FROM public.alertas_desaparecidos
WHERE estado = 'ACTIVA';

GRANT SELECT ON public.v_alertas_activas TO authenticated;

CREATE OR REPLACE FUNCTION public.crear_alerta_desaparecido(
  p_nombre_persona TEXT,
  p_edad_aprox INTEGER,
  p_vestimenta TEXT,
  p_foto_url TEXT,
  p_lat DOUBLE PRECISION,
  p_lng DOUBLE PRECISION,
  p_radio_km INTEGER DEFAULT 5,
  p_ultima_vista_texto TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_emisor_id UUID;
  v_alerta_id UUID;
  v_score INTEGER;
  v_fecha_registro TIMESTAMPTZ;
  v_alertas_recientes INTEGER;
  v_activas INTEGER;
BEGIN
  SELECT id, score_confiabilidad, fecha_registro
  INTO v_emisor_id, v_score, v_fecha_registro
  FROM public.usuarios
  WHERE auth_user_id = auth.uid();

  IF v_emisor_id IS NULL THEN
    RAISE EXCEPTION 'Perfil de usuario no encontrado. Reinicia la app.';
  END IF;

  IF v_score < 40 THEN
    RAISE EXCEPTION 'Tu cuenta tiene restricciones por reportes previos. Contacta soporte.';
  END IF;

  SELECT COUNT(*)::INTEGER INTO v_activas
  FROM public.alertas_desaparecidos
  WHERE emisor_id = v_emisor_id AND estado = 'ACTIVA';

  IF v_activas >= 1 THEN
    RAISE EXCEPTION 'Ya tienes una alerta activa. Resuélvela antes de emitir otra.';
  END IF;

  IF v_fecha_registro > (now() - INTERVAL '24 hours') THEN
    SELECT COUNT(*)::INTEGER INTO v_alertas_recientes
    FROM public.alertas_desaparecidos
    WHERE emisor_id = v_emisor_id
      AND creado_en > (now() - INTERVAL '24 hours');

    IF v_alertas_recientes >= 1 THEN
      RAISE EXCEPTION 'Cuentas nuevas: máximo 1 alerta en las primeras 24 horas.';
    END IF;
  END IF;

  INSERT INTO public.alertas_desaparecidos (
    emisor_id,
    nombre_persona,
    edad_aprox,
    vestimenta,
    foto_url,
    ubicacion_origen,
    radio_km,
    ultima_vista_texto
  ) VALUES (
    v_emisor_id,
    p_nombre_persona,
    p_edad_aprox,
    NULLIF(trim(p_vestimenta), ''),
    p_foto_url,
    ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
    p_radio_km,
    NULLIF(trim(p_ultima_vista_texto), '')
  )
  RETURNING id INTO v_alerta_id;

  RETURN v_alerta_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.obtener_alerta(p_alerta_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT json_build_object(
    'id', ad.id,
    'emisor_id', ad.emisor_id,
    'nombre_persona', ad.nombre_persona,
    'edad_aprox', ad.edad_aprox,
    'vestimenta', ad.vestimenta,
    'ultima_vista_texto', ad.ultima_vista_texto,
    'foto_url', ad.foto_url,
    'radio_km', ad.radio_km,
    'creado_en', ad.creado_en,
    'lat', ST_Y(ad.ubicacion_origen::geometry),
    'lng', ST_X(ad.ubicacion_origen::geometry)
  ) INTO v_result
  FROM public.alertas_desaparecidos ad
  WHERE ad.id = p_alerta_id
    AND (
      ad.estado IN ('ACTIVA', 'RESUELTA')
      OR ad.emisor_id IN (
        SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
      )
    );

  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Alerta no disponible';
  END IF;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.registrar_avistamiento(
  p_alerta_id UUID,
  p_lat DOUBLE PRECISION DEFAULT NULL,
  p_lng DOUBLE PRECISION DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_testigo_id UUID;
  v_avistamiento_id UUID;
  v_lat DOUBLE PRECISION;
  v_lng DOUBLE PRECISION;
BEGIN
  SELECT id INTO v_testigo_id
  FROM public.usuarios
  WHERE auth_user_id = auth.uid();

  IF v_testigo_id IS NULL THEN
    RAISE EXCEPTION 'Perfil de usuario no encontrado';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.alertas_desaparecidos
    WHERE id = p_alerta_id AND estado = 'ACTIVA'
  ) THEN
    RAISE EXCEPTION 'La alerta no está activa';
  END IF;

  IF p_lat IS NOT NULL AND p_lng IS NOT NULL THEN
    v_lat := p_lat;
    v_lng := p_lng;
  ELSE
    SELECT
      ST_Y(ultima_ubicacion::geometry),
      ST_X(ultima_ubicacion::geometry)
    INTO v_lat, v_lng
    FROM public.usuarios
    WHERE id = v_testigo_id;
  END IF;

  IF v_lat IS NULL OR v_lng IS NULL THEN
    RAISE EXCEPTION 'Marca en el mapa dónde lo viste o activa el GPS';
  END IF;

  INSERT INTO public.reacciones_avistamientos (
    alerta_id,
    testigo_id,
    ubicacion_testigo
  ) VALUES (
    p_alerta_id,
    v_testigo_id,
    ST_SetSRID(ST_MakePoint(v_lng, v_lat), 4326)::geography
  )
  ON CONFLICT (alerta_id, testigo_id) DO UPDATE
  SET
    ubicacion_testigo = EXCLUDED.ubicacion_testigo,
    fecha_reporte = now()
  RETURNING id INTO v_avistamiento_id;

  RETURN v_avistamiento_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.resumen_avistamientos(p_alerta_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
  v_origen GEOGRAPHY;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.alertas_desaparecidos ad
    WHERE ad.id = p_alerta_id
      AND ad.emisor_id IN (
        SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
      )
  ) THEN
    RAISE EXCEPTION 'Solo el emisor puede ver avistamientos';
  END IF;

  SELECT ubicacion_origen INTO v_origen
  FROM public.alertas_desaparecidos
  WHERE id = p_alerta_id;

  SELECT COALESCE(json_agg(row_to_json(t) ORDER BY t.hace_minutos ASC), '[]'::json)
  INTO v_result
  FROM (
    SELECT
      ROUND(
        (ST_Distance(v_origen, ra.ubicacion_testigo) / 1000.0)::numeric,
        1
      ) AS distancia_km,
      GREATEST(0, EXTRACT(EPOCH FROM (now() - ra.fecha_reporte)) / 60)::INTEGER AS hace_minutos
    FROM public.reacciones_avistamientos ra
    WHERE ra.alerta_id = p_alerta_id
    ORDER BY ra.fecha_reporte DESC
    LIMIT 10
  ) t;

  RETURN v_result;
END;
$$;

REVOKE ALL ON FUNCTION public.resumen_avistamientos FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.resumen_avistamientos TO authenticated;
