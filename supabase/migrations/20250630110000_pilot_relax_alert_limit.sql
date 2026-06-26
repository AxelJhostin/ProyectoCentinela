-- Piloto: relajar límite de alertas para cuentas nuevas (pruebas en campo)

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
