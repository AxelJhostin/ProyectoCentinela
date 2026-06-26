-- Sprint 2: Storage, vista geo, RPCs de alertas y ubicación de usuario

-- Bucket de fotos (público lectura para MVP / previews)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'centinela-fotos',
  'centinela-fotos',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Storage RLS
CREATE POLICY centinela_fotos_select ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'centinela-fotos');

CREATE POLICY centinela_fotos_insert ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'centinela-fotos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY centinela_fotos_update ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'centinela-fotos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'centinela-fotos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY centinela_fotos_delete ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'centinela-fotos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Vista con lat/lng para el cliente Flutter
CREATE OR REPLACE VIEW public.v_alertas_activas
WITH (security_invoker = true) AS
SELECT
  id,
  emisor_id,
  nombre_persona,
  edad_aprox,
  vestimenta,
  foto_url,
  radio_km,
  estado,
  creado_en,
  ST_Y(ubicacion_origen::geometry) AS lat,
  ST_X(ubicacion_origen::geometry) AS lng
FROM public.alertas_desaparecidos
WHERE estado = 'ACTIVA';

GRANT SELECT ON public.v_alertas_activas TO authenticated;

-- Actualizar ubicación del usuario (geofencing Sprint 3)
CREATE OR REPLACE FUNCTION public.actualizar_mi_ubicacion(
  p_lat DOUBLE PRECISION,
  p_lng DOUBLE PRECISION
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.usuarios
  SET
    ultima_ubicacion = ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
    ubicacion_actualizada_en = now()
  WHERE auth_user_id = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION public.actualizar_mi_ubicacion FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.actualizar_mi_ubicacion TO authenticated;

-- Crear alerta con coordenadas
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
BEGIN
  SELECT id INTO v_emisor_id
  FROM public.usuarios
  WHERE auth_user_id = auth.uid();

  IF v_emisor_id IS NULL THEN
    RAISE EXCEPTION 'Perfil de usuario no encontrado. Reinicia la app.';
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

REVOKE ALL ON FUNCTION public.crear_alerta_desaparecido FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.crear_alerta_desaparecido TO authenticated;

-- Marcar alerta como resuelta (emisor)
CREATE OR REPLACE FUNCTION public.resolver_alerta(p_alerta_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.alertas_desaparecidos
  SET estado = 'RESUELTA'
  WHERE id = p_alerta_id
    AND emisor_id IN (
      SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
    );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No autorizado o alerta no encontrada';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.resolver_alerta FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.resolver_alerta TO authenticated;
