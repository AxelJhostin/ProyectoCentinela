-- Sprint 10: compartidos, admin y retención

CREATE TABLE IF NOT EXISTS public.eventos_compartir (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  alerta_id UUID NOT NULL REFERENCES public.alertas_desaparecidos (id) ON DELETE CASCADE,
  usuario_id UUID NOT NULL REFERENCES public.usuarios (id) ON DELETE CASCADE,
  canal TEXT NOT NULL DEFAULT 'whatsapp',
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_eventos_compartir_alerta
  ON public.eventos_compartir (alerta_id, creado_en DESC);

ALTER TABLE public.eventos_compartir ENABLE ROW LEVEL SECURITY;

CREATE POLICY eventos_compartir_insert ON public.eventos_compartir
  FOR INSERT TO authenticated
  WITH CHECK (
    usuario_id IN (SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid())
  );

CREATE OR REPLACE FUNCTION public.registrar_compartir_alerta(
  p_alerta_id UUID,
  p_canal TEXT DEFAULT 'whatsapp'
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_usuario_id UUID;
  v_total INTEGER;
BEGIN
  SELECT id INTO v_usuario_id
  FROM public.usuarios
  WHERE auth_user_id = auth.uid();

  IF v_usuario_id IS NULL THEN
    RAISE EXCEPTION 'Perfil de usuario no encontrado';
  END IF;

  INSERT INTO public.eventos_compartir (alerta_id, usuario_id, canal)
  VALUES (p_alerta_id, v_usuario_id, COALESCE(NULLIF(trim(p_canal), ''), 'whatsapp'));

  SELECT COUNT(*)::INTEGER INTO v_total
  FROM public.eventos_compartir
  WHERE alerta_id = p_alerta_id;

  RETURN v_total;
END;
$$;

CREATE OR REPLACE FUNCTION public.contar_compartidos_alerta(p_alerta_id UUID)
RETURNS INTEGER
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COUNT(*)::INTEGER
  FROM public.eventos_compartir
  WHERE alerta_id = p_alerta_id;
$$;

REVOKE ALL ON FUNCTION public.registrar_compartir_alerta FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.registrar_compartir_alerta TO authenticated;
REVOKE ALL ON FUNCTION public.contar_compartidos_alerta FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.contar_compartidos_alerta TO authenticated;

-- Administradores
CREATE TABLE IF NOT EXISTS public.administradores (
  auth_user_id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.administradores ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.es_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.administradores WHERE auth_user_id = auth.uid()
  );
$$;

CREATE POLICY app_logs_admin_select ON public.app_logs
  FOR SELECT TO authenticated
  USING (public.es_admin());

CREATE OR REPLACE FUNCTION public.admin_listar_alertas(
  p_estado TEXT DEFAULT NULL,
  p_limite INTEGER DEFAULT 50
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
BEGIN
  IF NOT public.es_admin() THEN
    RAISE EXCEPTION 'Acceso denegado';
  END IF;

  SELECT COALESCE(json_agg(row_to_json(t) ORDER BY t.creado_en DESC), '[]'::json)
  INTO v_result
  FROM (
    SELECT
      ad.id,
      ad.nombre_persona,
      ad.estado::TEXT AS estado,
      ad.creado_en,
      ad.radio_km,
      u.score_confiabilidad
    FROM public.alertas_desaparecidos ad
    JOIN public.usuarios u ON u.id = ad.emisor_id
    WHERE p_estado IS NULL OR ad.estado::TEXT = p_estado
    ORDER BY ad.creado_en DESC
    LIMIT LEAST(p_limite, 100)
  ) t;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_forzar_estado(
  p_alerta_id UUID,
  p_estado TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.es_admin() THEN
    RAISE EXCEPTION 'Acceso denegado';
  END IF;

  UPDATE public.alertas_desaparecidos
  SET estado = p_estado::public.estado_alerta
  WHERE id = p_alerta_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_ajustar_score(
  p_usuario_id UUID,
  p_score INTEGER
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.es_admin() THEN
    RAISE EXCEPTION 'Acceso denegado';
  END IF;

  UPDATE public.usuarios
  SET score_confiabilidad = GREATEST(0, LEAST(100, p_score))
  WHERE id = p_usuario_id;
END;
$$;

REVOKE ALL ON FUNCTION public.es_admin FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.es_admin TO authenticated;
REVOKE ALL ON FUNCTION public.admin_listar_alertas FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_listar_alertas TO authenticated;
REVOKE ALL ON FUNCTION public.admin_forzar_estado FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_forzar_estado TO authenticated;
REVOKE ALL ON FUNCTION public.admin_ajustar_score FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_ajustar_score TO authenticated;

-- Retención
CREATE OR REPLACE FUNCTION public.archivar_alertas_antiguas()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  DELETE FROM public.alertas_desaparecidos
  WHERE estado IN ('RESUELTA', 'FALSA_ALARMA')
    AND creado_en < (now() - INTERVAL '90 days');

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.archivar_alertas_antiguas FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.archivar_alertas_antiguas TO service_role;
