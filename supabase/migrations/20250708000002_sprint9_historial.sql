-- Sprint 9: historial de alertas resueltas/cerradas

CREATE OR REPLACE VIEW public.v_alertas_historial
WITH (security_invoker = true)
AS
SELECT
  ad.id,
  ad.emisor_id,
  ad.nombre_persona,
  ad.edad_aprox,
  ad.vestimenta,
  ad.ultima_vista_texto,
  ad.foto_url,
  ad.radio_km,
  ad.estado::TEXT AS estado,
  ad.creado_en,
  ST_Y(ad.ubicacion_origen::geometry) AS lat,
  ST_X(ad.ubicacion_origen::geometry) AS lng
FROM public.alertas_desaparecidos ad
WHERE ad.estado IN ('RESUELTA', 'FALSA_ALARMA')
  AND ad.creado_en > (now() - INTERVAL '30 days');

GRANT SELECT ON public.v_alertas_historial TO authenticated;

CREATE OR REPLACE FUNCTION public.listar_historial_cercano(
  p_lat DOUBLE PRECISION,
  p_lng DOUBLE PRECISION,
  p_radio_km INTEGER DEFAULT 50
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
  v_origen GEOGRAPHY;
BEGIN
  v_origen := ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography;

  SELECT COALESCE(json_agg(row_to_json(t) ORDER BY t.creado_en DESC), '[]'::json)
  INTO v_result
  FROM (
    SELECT
      h.id,
      h.emisor_id,
      h.nombre_persona,
      h.edad_aprox,
      h.vestimenta,
      h.ultima_vista_texto,
      h.foto_url,
      h.radio_km,
      h.estado,
      h.creado_en,
      h.lat,
      h.lng,
      ROUND(
        (ST_Distance(v_origen, ST_SetSRID(ST_MakePoint(h.lng, h.lat), 4326)::geography) / 1000.0)::numeric,
        1
      ) AS distancia_km
    FROM public.v_alertas_historial h
    WHERE ST_DWithin(
      v_origen,
      ST_SetSRID(ST_MakePoint(h.lng, h.lat), 4326)::geography,
      p_radio_km * 1000
    )
    ORDER BY h.creado_en DESC
    LIMIT 50
  ) t;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.listar_mi_historial()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_emisor_id UUID;
  v_result JSON;
BEGIN
  SELECT id INTO v_emisor_id
  FROM public.usuarios
  WHERE auth_user_id = auth.uid();

  IF v_emisor_id IS NULL THEN
    RAISE EXCEPTION 'Perfil de usuario no encontrado';
  END IF;

  SELECT COALESCE(json_agg(row_to_json(t) ORDER BY t.creado_en DESC), '[]'::json)
  INTO v_result
  FROM (
    SELECT
      h.id,
      h.emisor_id,
      h.nombre_persona,
      h.edad_aprox,
      h.vestimenta,
      h.ultima_vista_texto,
      h.foto_url,
      h.radio_km,
      h.estado,
      h.creado_en,
      h.lat,
      h.lng,
      0::numeric AS distancia_km
    FROM public.v_alertas_historial h
    WHERE h.emisor_id = v_emisor_id
    ORDER BY h.creado_en DESC
    LIMIT 50
  ) t;

  RETURN v_result;
END;
$$;

REVOKE ALL ON FUNCTION public.listar_historial_cercano FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.listar_historial_cercano TO authenticated;
REVOKE ALL ON FUNCTION public.listar_mi_historial FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.listar_mi_historial TO authenticated;
