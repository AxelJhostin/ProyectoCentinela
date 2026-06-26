import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { sendFcm } from "../_shared/fcm.ts";

interface Body {
  alerta_id: string;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  if (!Deno.env.get("FIREBASE_SERVICE_ACCOUNT") && !Deno.env.get("FCM_SERVER_KEY")) {
    return json({ ok: false, message: "FCM no configurado en Supabase Secrets" });
  }

  const { alerta_id } = (await req.json()) as Body;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: alerta, error } = await supabase
    .from("alertas_desaparecidos")
    .select("nombre_persona, emisor_id")
    .eq("id", alerta_id)
    .maybeSingle();

  if (error || !alerta) {
    return json({ ok: false, error: "Alerta no encontrada" }, 404);
  }

  const { data: emisor } = await supabase
    .from("usuarios")
    .select("fcm_token")
    .eq("id", alerta.emisor_id)
    .maybeSingle();

  const token = emisor?.fcm_token as string | null;
  if (!token) {
    return json({ ok: false, sent: 0, message: "Emisor sin token FCM" });
  }

  const ok = await sendFcm(
    token,
    "👁 Nuevo avistamiento",
    `Alguien reportó haber visto a ${alerta.nombre_persona}.`,
    { alerta_id, tipo: "avistamiento" },
  );

  return json({ ok, sent: ok ? 1 : 0 });
});

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
