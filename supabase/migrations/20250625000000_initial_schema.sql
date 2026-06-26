-- Proyecto Centinela — Esquema inicial MVP
-- Ejecutar SOLO en el proyecto Supabase dedicado (centinela-mvp), NUNCA en RECI.

CREATE EXTENSION IF NOT EXISTS postgis;

-- ---------------------------------------------------------------------------
-- Tabla: usuarios
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE REFERENCES auth.users (id) ON DELETE CASCADE,
    telefono_o_email TEXT,
    fcm_token TEXT,
    ultima_ubicacion GEOGRAPHY(POINT, 4326),
    ubicacion_actualizada_en TIMESTAMPTZ,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT now(),
    score_confiabilidad INTEGER NOT NULL DEFAULT 100 CHECK (score_confiabilidad BETWEEN 0 AND 100)
);

CREATE INDEX IF NOT EXISTS idx_usuarios_ultima_ubicacion
    ON public.usuarios USING GIST (ultima_ubicacion);

CREATE INDEX IF NOT EXISTS idx_usuarios_fcm_token
    ON public.usuarios (fcm_token)
    WHERE fcm_token IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Tabla: alertas_desaparecidos
-- ---------------------------------------------------------------------------
CREATE TYPE public.estado_alerta AS ENUM ('ACTIVA', 'RESUELTA', 'FALSA_ALARMA');

CREATE TABLE IF NOT EXISTS public.alertas_desaparecidos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    emisor_id UUID NOT NULL REFERENCES public.usuarios (id) ON DELETE RESTRICT,
    nombre_persona TEXT NOT NULL,
    edad_aprox INTEGER NOT NULL CHECK (edad_aprox > 0 AND edad_aprox < 150),
    vestimenta TEXT,
    foto_url TEXT NOT NULL,
    ubicacion_origen GEOGRAPHY(POINT, 4326) NOT NULL,
    radio_km INTEGER NOT NULL DEFAULT 5 CHECK (radio_km BETWEEN 1 AND 50),
    estado public.estado_alerta NOT NULL DEFAULT 'ACTIVA',
    creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_alertas_ubicacion_origen
    ON public.alertas_desaparecidos USING GIST (ubicacion_origen);

CREATE INDEX IF NOT EXISTS idx_alertas_estado_creado
    ON public.alertas_desaparecidos (estado, creado_en DESC);

-- ---------------------------------------------------------------------------
-- Tabla: reacciones_avistamientos
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reacciones_avistamientos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alerta_id UUID NOT NULL REFERENCES public.alertas_desaparecidos (id) ON DELETE CASCADE,
    testigo_id UUID NOT NULL REFERENCES public.usuarios (id) ON DELETE RESTRICT,
    ubicacion_testigo GEOGRAPHY(POINT, 4326) NOT NULL,
    fecha_reporte TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (alerta_id, testigo_id)
);

CREATE INDEX IF NOT EXISTS idx_avistamientos_alerta
    ON public.reacciones_avistamientos (alerta_id, fecha_reporte DESC);

-- ---------------------------------------------------------------------------
-- RLS (habilitar en todas las tablas expuestas)
-- ---------------------------------------------------------------------------
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alertas_desaparecidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reacciones_avistamientos ENABLE ROW LEVEL SECURITY;

-- Políticas mínimas: ajustar en Sprint 2 según flujo de auth real.
-- Por ahora: usuarios solo leen/escriben su propio registro.
CREATE POLICY usuarios_select_own ON public.usuarios
    FOR SELECT TO authenticated
    USING (auth.uid() = auth_user_id);

CREATE POLICY usuarios_update_own ON public.usuarios
    FOR UPDATE TO authenticated
    USING (auth.uid() = auth_user_id)
    WITH CHECK (auth.uid() = auth_user_id);

CREATE POLICY usuarios_insert_own ON public.usuarios
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = auth_user_id);

-- Alertas activas visibles para usuarios autenticados; emisor puede actualizar las suyas.
CREATE POLICY alertas_select_authenticated ON public.alertas_desaparecidos
    FOR SELECT TO authenticated
    USING (estado = 'ACTIVA' OR emisor_id IN (
        SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
    ));

CREATE POLICY alertas_insert_emisor ON public.alertas_desaparecidos
    FOR INSERT TO authenticated
    WITH CHECK (emisor_id IN (
        SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
    ));

CREATE POLICY alertas_update_emisor ON public.alertas_desaparecidos
    FOR UPDATE TO authenticated
    USING (emisor_id IN (
        SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
    ));

-- Avistamientos: insertar como testigo autenticado; leer propios o si eres emisor de la alerta.
CREATE POLICY avistamientos_insert ON public.reacciones_avistamientos
    FOR INSERT TO authenticated
    WITH CHECK (testigo_id IN (
        SELECT id FROM public.usuarios WHERE auth_user_id = auth.uid()
    ));

-- ---------------------------------------------------------------------------
-- Función auxiliar: usuarios dentro de radio (para Edge Function / Sprint 3)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.usuarios_en_radio(
    origen_lat DOUBLE PRECISION,
    origen_lng DOUBLE PRECISION,
    radio_metros DOUBLE PRECISION
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
      AND ST_DWithin(
            u.ultima_ubicacion,
            ST_SetSRID(ST_MakePoint(origen_lng, origen_lat), 4326)::geography,
            radio_metros
          );
$$;

REVOKE ALL ON FUNCTION public.usuarios_en_radio FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.usuarios_en_radio TO service_role;
