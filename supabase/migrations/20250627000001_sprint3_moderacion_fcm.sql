-- Sprint 3: FCM token, límites de emisión, post-moderación

CREATE OR REPLACE FUNCTION public.actualizar_fcm_token(p_token TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.usuarios
  SET fcm_token = NULLIF(trim(p_token), '')
  WHERE auth_user_id = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION public.actualizar_fcm_token FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.actualizar_fcm_token TO authenticated;

-- Reportes de alertas falsas
CREATE TABLE IF NOT EXISTS public.reportes_alerta (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  alerta_id UUID NOT NULL REFERENCES public.alertas_desaparecidos (id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES public.usuarios (id) ON DELETE CASCADE,
  motivo TEXT,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (alerta_id, reporter_id)
);

ALTER TABLE public.reportes_alerta ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS reportes_insert ON public.reportes_alerta;
CREATE POLICY reportes_insert ON public.reportes_alerta
  FOR INSERT TO authenticated
  WITH CHECK (
    reporter_id IN (SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid())
  );

DROP POLICY IF EXISTS reportes_select_own ON public.reportes_alerta;
CREATE POLICY reportes_select_own ON public.reportes_alerta
  FOR SELECT TO authenticated
  USING (
    reporter_id IN (SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid())
  );

CREATE OR REPLACE FUNCTION public.reportar_alerta_falsa(
  p_alerta_id UUID,
  p_motivo TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_reporter_id UUID;
  v_emisor_id UUID;
  v_reportes INTEGER;
BEGIN
  SELECT id INTO v_reporter_id
  FROM public.usuarios
  WHERE auth_user_id = auth.uid();

  IF v_reporter_id IS NULL THEN
    RAISE EXCEPTION 'Perfil de usuario no encontrado';
  END IF;

  SELECT emisor_id INTO v_emisor_id
  FROM public.alertas_desaparecidos
  WHERE id = p_alerta_id AND estado = 'ACTIVA';

  IF v_emisor_id IS NULL THEN
    RAISE EXCEPTION 'Alerta no encontrada o ya no está activa';
  END IF;

  IF v_emisor_id = v_reporter_id THEN
    RAISE EXCEPTION 'No puedes reportar tu propia alerta';
  END IF;

  INSERT INTO public.reportes_alerta (alerta_id, reporter_id, motivo)
  VALUES (p_alerta_id, v_reporter_id, NULLIF(trim(p_motivo), ''))
  ON CONFLICT (alerta_id, reporter_id) DO NOTHING;

  UPDATE public.usuarios
  SET score_confiabilidad = GREATEST(0, score_confiabilidad - 10)
  WHERE id = v_emisor_id;

  SELECT COUNT(*)::INTEGER INTO v_reportes
  FROM public.reportes_alerta
  WHERE alerta_id = p_alerta_id;

  IF v_reportes >= 3 THEN
    UPDATE public.alertas_desaparecidos
    SET estado = 'FALSA_ALARMA'
    WHERE id = p_alerta_id;
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.reportar_alerta_falsa FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.reportar_alerta_falsa TO authenticated;

-- Límites al crear alerta (cuentas nuevas + score bajo)
CREATE OR REPLACE FUNCTION public.crear_alerta_desaparecido(
  p_nombre_persona TEXT,
  p_edad_aprox INTEGER,
  p_vestimenta TEXT,
  p_foto_url TEXT,
  p_lat DOUBLE PRECISION,
  p_lng DOUBLE PRECISION,
  p_radio_km INTEGER DEFAULT 5
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
    radio_km
  ) VALUES (
    v_emisor_id,
    p_nombre_persona,
    p_edad_aprox,
    NULLIF(trim(p_vestimenta), ''),
    p_foto_url,
    ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
    p_radio_km
  )
  RETURNING id INTO v_alerta_id;

  RETURN v_alerta_id;
END;
$$;

-- Detalle de alerta para deep links (oculta FALSA_ALARMA a la comunidad)
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

REVOKE ALL ON FUNCTION public.obtener_alerta FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.obtener_alerta TO authenticated;
