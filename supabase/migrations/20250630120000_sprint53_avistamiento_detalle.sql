-- Sprint 5.3: detalle de avistamientos para emisor + radio piloto

ALTER TABLE public.reacciones_avistamientos
  ADD COLUMN IF NOT EXISTS nota_testigo TEXT,
  ADD COLUMN IF NOT EXISTS ubicacion_texto TEXT;

CREATE OR REPLACE FUNCTION public.registrar_avistamiento(
  p_alerta_id UUID,
  p_lat DOUBLE PRECISION DEFAULT NULL,
  p_lng DOUBLE PRECISION DEFAULT NULL,
  p_nota_testigo TEXT DEFAULT NULL,
  p_ubicacion_texto TEXT DEFAULT NULL
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
    ubicacion_testigo,
    nota_testigo,
    ubicacion_texto
  ) VALUES (
    p_alerta_id,
    v_testigo_id,
    ST_SetSRID(ST_MakePoint(v_lng, v_lat), 4326)::geography,
    NULLIF(trim(p_nota_testigo), ''),
    NULLIF(trim(p_ubicacion_texto), '')
  )
  ON CONFLICT (alerta_id, testigo_id) DO UPDATE
  SET
    ubicacion_testigo = EXCLUDED.ubicacion_testigo,
    nota_testigo = EXCLUDED.nota_testigo,
    ubicacion_texto = EXCLUDED.ubicacion_texto,
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
      GREATEST(0, EXTRACT(EPOCH FROM (now() - ra.fecha_reporte)) / 60)::INTEGER AS hace_minutos,
      ST_Y(ra.ubicacion_testigo::geometry) AS lat,
      ST_X(ra.ubicacion_testigo::geometry) AS lng,
      ra.nota_testigo,
      ra.ubicacion_texto
    FROM public.reacciones_avistamientos ra
    WHERE ra.alerta_id = p_alerta_id
    ORDER BY ra.fecha_reporte DESC
    LIMIT 10
  ) t;

  RETURN v_result;
END;
$$;
