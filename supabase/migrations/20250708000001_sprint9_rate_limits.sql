-- Sprint 9: rate limits más finos

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
  v_ultima_resuelta TIMESTAMPTZ;
  v_falsas_7d INTEGER;
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

  SELECT COUNT(*)::INTEGER INTO v_falsas_7d
  FROM public.alertas_desaparecidos
  WHERE emisor_id = v_emisor_id
    AND estado = 'FALSA_ALARMA'
    AND creado_en > (now() - INTERVAL '7 days');

  IF v_falsas_7d >= 2 THEN
    UPDATE public.usuarios
    SET score_confiabilidad = GREATEST(0, score_confiabilidad - 20)
    WHERE id = v_emisor_id;
    RAISE EXCEPTION 'Tu cuenta tiene restricciones por reportes previos. Contacta soporte.';
  END IF;

  SELECT COUNT(*)::INTEGER INTO v_activas
  FROM public.alertas_desaparecidos
  WHERE emisor_id = v_emisor_id AND estado = 'ACTIVA';

  IF v_activas >= 1 THEN
    RAISE EXCEPTION 'Ya tienes una alerta activa. Resuélvela antes de emitir otra.';
  END IF;

  SELECT MAX(creado_en) INTO v_ultima_resuelta
  FROM public.alertas_desaparecidos
  WHERE emisor_id = v_emisor_id AND estado = 'RESUELTA';

  IF v_ultima_resuelta IS NOT NULL
     AND v_ultima_resuelta > (now() - INTERVAL '15 minutes') THEN
    RAISE EXCEPTION 'Espera 15 minutos después de resolver una alerta antes de emitir otra.';
  END IF;

  IF v_fecha_registro > (now() - INTERVAL '24 hours') THEN
    SELECT COUNT(*)::INTEGER INTO v_alertas_recientes
    FROM public.alertas_desaparecidos
    WHERE emisor_id = v_emisor_id
      AND creado_en > (now() - INTERVAL '24 hours');

    IF v_alertas_recientes >= 3 THEN
      RAISE EXCEPTION 'Cuentas nuevas: máximo 3 alertas en las primeras 24 horas.';
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
  v_avistamientos_hora INTEGER;
BEGIN
  SELECT id INTO v_testigo_id
  FROM public.usuarios
  WHERE auth_user_id = auth.uid();

  IF v_testigo_id IS NULL THEN
    RAISE EXCEPTION 'Perfil de usuario no encontrado';
  END IF;

  SELECT COUNT(*)::INTEGER INTO v_avistamientos_hora
  FROM public.reacciones_avistamientos
  WHERE testigo_id = v_testigo_id
    AND fecha_reporte > (now() - INTERVAL '1 hour');

  IF v_avistamientos_hora >= 10 THEN
    RAISE EXCEPTION 'Has reportado muchos avistamientos. Espera un momento e intenta de nuevo.';
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
