-- Sprint 3: avistamientos + políticas de lectura

CREATE OR REPLACE FUNCTION public.registrar_avistamiento(p_alerta_id UUID)
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

  -- Coordenadas del testigo: última ubicación conocida en usuarios
  SELECT
    ST_Y(ultima_ubicacion::geometry),
    ST_X(ultima_ubicacion::geometry)
  INTO v_lat, v_lng
  FROM public.usuarios
  WHERE id = v_testigo_id;

  IF v_lat IS NULL OR v_lng IS NULL THEN
    RAISE EXCEPTION 'Activa el GPS para reportar tu ubicación';
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

REVOKE ALL ON FUNCTION public.registrar_avistamiento FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.registrar_avistamiento TO authenticated;

CREATE POLICY avistamientos_select ON public.reacciones_avistamientos
  FOR SELECT TO authenticated
  USING (
    testigo_id IN (SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid())
    OR alerta_id IN (
      SELECT ad.id FROM public.alertas_desaparecidos ad
      JOIN public.usuarios u ON u.id = ad.emisor_id
      WHERE u.auth_user_id = auth.uid()
    )
  );
