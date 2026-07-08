import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

export async function registrarLog(
  nivel: string,
  origen: string,
  evento: string,
  payload?: Record<string, unknown>,
): Promise<void> {
  try {
    const url = Deno.env.get("SUPABASE_URL");
    const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!url || !key) return;

    const supabase = createClient(url, key);
    await supabase.rpc("registrar_log", {
      p_nivel: nivel,
      p_origen: origen,
      p_evento: evento,
      p_payload: payload ?? null,
    });
  } catch (_) {
    // No bloquear el flujo principal por fallo de log.
  }
}
