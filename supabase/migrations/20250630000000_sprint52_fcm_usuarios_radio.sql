-- Sprint 5.2: excluir emisor del push comunitario

CREATE OR REPLACE FUNCTION public.usuarios_en_radio(
  origen_lat DOUBLE PRECISION,
  origen_lng DOUBLE PRECISION,
  radio_metros DOUBLE PRECISION,
  p_excluir_usuario_id UUID DEFAULT NULL
)
RETURNS TABLE (usuario_id UUID, fcm_token TEXT)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT u.id, u.fcm_token
  FROM public.usuarios u
  WHERE u.fcm_token IS NOT NULL
    AND u.ultima_ubicacion IS NOT NULL
    AND u.ubicacion_actualizada_en > now() - INTERVAL '24 hours'
    AND (p_excluir_usuario_id IS NULL OR u.id != p_excluir_usuario_id)
    AND ST_DWithin(
      u.ultima_ubicacion,
      ST_SetSRID(ST_MakePoint(origen_lng, origen_lat), 4326)::geography,
      radio_metros
    );
$$;
