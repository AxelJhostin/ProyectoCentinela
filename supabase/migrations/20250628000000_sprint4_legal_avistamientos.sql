-- Sprint 4: consentimiento LOPDP + conteo avistamientos para emisor

ALTER TABLE public.usuarios
  ADD COLUMN IF NOT EXISTS consentimiento_lopdp_en TIMESTAMPTZ;

CREATE OR REPLACE FUNCTION public.registrar_consentimiento_lopdp()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.usuarios
  SET consentimiento_lopdp_en = now()
  WHERE auth_user_id = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION public.registrar_consentimiento_lopdp FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.registrar_consentimiento_lopdp TO authenticated;

CREATE OR REPLACE FUNCTION public.contar_avistamientos(p_alerta_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.alertas_desaparecidos ad
    WHERE ad.id = p_alerta_id
      AND (
        ad.estado IN ('ACTIVA', 'RESUELTA')
        OR ad.emisor_id IN (
          SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
        )
      )
  ) THEN
    RAISE EXCEPTION 'Alerta no disponible';
  END IF;

  SELECT COUNT(*)::INTEGER INTO v_count
  FROM public.reacciones_avistamientos
  WHERE alerta_id = p_alerta_id;

  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.contar_avistamientos FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.contar_avistamientos TO authenticated;
