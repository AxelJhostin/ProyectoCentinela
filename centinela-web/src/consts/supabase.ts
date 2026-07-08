/// Clave pública de Supabase (segura en frontend). Override con variables PUBLIC_* en Vercel.
export const SUPABASE_URL =
  import.meta.env.PUBLIC_SUPABASE_URL ?? 'https://wziwufumjtpjqyuzzzyn.supabase.co';

export const SUPABASE_ANON_KEY =
  import.meta.env.PUBLIC_SUPABASE_ANON_KEY ??
  'sb_publishable_Xy3BguFe-sDP72XIveo_xA_cOqOOEk-';

export type SiteEventType = 'visita' | 'descarga_apk' | 'compartido';

export interface SiteMetrics {
  visitas: number;
  descargas_apk: number;
  compartidos: number;
  actualizado_en?: string;
}
