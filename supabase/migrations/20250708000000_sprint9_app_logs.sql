-- Sprint 9: logs centralizados

CREATE TABLE IF NOT EXISTS public.app_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nivel TEXT NOT NULL CHECK (nivel IN ('debug', 'info', 'warn', 'error')),
  origen TEXT NOT NULL,
  evento TEXT NOT NULL,
  payload JSONB,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_app_logs_creado ON public.app_logs (creado_en DESC);
CREATE INDEX IF NOT EXISTS idx_app_logs_origen ON public.app_logs (origen, evento);

ALTER TABLE public.app_logs ENABLE ROW LEVEL SECURITY;

-- Solo admins leen logs (tabla administradores se crea en Sprint 10).
-- Inserción vía RPC o service role.

CREATE OR REPLACE FUNCTION public.registrar_log(
  p_nivel TEXT,
  p_origen TEXT,
  p_evento TEXT,
  p_payload JSONB DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.app_logs (nivel, origen, evento, payload)
  VALUES (
    p_nivel,
    p_origen,
    p_evento,
    p_payload
  );
END;
$$;

REVOKE ALL ON FUNCTION public.registrar_log FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.registrar_log TO authenticated;
GRANT EXECUTE ON FUNCTION public.registrar_log TO service_role;
