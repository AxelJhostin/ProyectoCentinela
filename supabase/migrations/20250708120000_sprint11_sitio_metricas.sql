-- Sprint 11: métricas públicas del sitio web (visitas, descargas, compartidos)

CREATE TABLE IF NOT EXISTS public.sitio_metricas (
  clave TEXT PRIMARY KEY,
  valor BIGINT NOT NULL DEFAULT 0 CHECK (valor >= 0),
  actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO public.sitio_metricas (clave, valor)
VALUES
  ('visitas', 0),
  ('descargas_apk', 0),
  ('compartidos', 0)
ON CONFLICT (clave) DO NOTHING;

ALTER TABLE public.sitio_metricas ENABLE ROW LEVEL SECURITY;

CREATE POLICY sitio_metricas_public_read
  ON public.sitio_metricas
  FOR SELECT
  USING (true);

CREATE OR REPLACE FUNCTION public.registrar_evento_sitio(p_tipo TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_clave TEXT;
BEGIN
  v_clave := CASE p_tipo
    WHEN 'visita' THEN 'visitas'
    WHEN 'descarga_apk' THEN 'descargas_apk'
    WHEN 'compartido' THEN 'compartidos'
    ELSE NULL
  END;

  IF v_clave IS NULL THEN
    RAISE EXCEPTION 'Tipo de evento no válido: %', p_tipo;
  END IF;

  INSERT INTO public.sitio_metricas (clave, valor)
  VALUES (v_clave, 1)
  ON CONFLICT (clave) DO UPDATE
  SET
    valor = public.sitio_metricas.valor + 1,
    actualizado_en = now();
END;
$$;

CREATE OR REPLACE FUNCTION public.obtener_metricas_sitio()
RETURNS JSON
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT json_build_object(
    'visitas', COALESCE((SELECT valor FROM public.sitio_metricas WHERE clave = 'visitas'), 0),
    'descargas_apk', COALESCE((SELECT valor FROM public.sitio_metricas WHERE clave = 'descargas_apk'), 0),
    'compartidos', COALESCE((SELECT valor FROM public.sitio_metricas WHERE clave = 'compartidos'), 0),
    'actualizado_en', (SELECT MAX(actualizado_en) FROM public.sitio_metricas)
  );
$$;

REVOKE ALL ON FUNCTION public.registrar_evento_sitio(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.registrar_evento_sitio(TEXT) TO anon, authenticated;

REVOKE ALL ON FUNCTION public.obtener_metricas_sitio() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.obtener_metricas_sitio() TO anon, authenticated;
