import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { sendFcm } from "../_shared/fcm.ts";
import { registrarLog } from "../_shared/logging.ts";

interface SharePushBody {
  alerta_id: string;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const body = (await req.json()) as SharePushBody;
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: alerta } = await supabase
    .from("alertas_desaparecidos")
    .select("emisor_id, nombre_persona, estado")
    .eq("id", body.alerta_id)
    .maybeSingle();

  if (!alerta || alerta.estado !== "ACTIVA") {
    return json({ ok: false, sent: 0, message: "Alerta no activa" });
  }

  const { data: emisor } = await supabase
    .from("usuarios")
    .select("fcm_token")
    .eq("id", alerta.emisor_id)
    .maybeSingle();

  const token = emisor?.fcm_token as string | null;
  if (!token) {
    await registrarLog("warn", "dispatch-share-push", "sin_token_emisor", {
      alerta_id: body.alerta_id,
    });
    return json({ ok: true, sent: 0, message: "Emisor sin token FCM" });
  }

  const { count: recientes } = await supabase
    .from("eventos_compartir")
    .select("id", { count: "exact", head: true })
    .eq("alerta_id", body.alerta_id)
    .gte("creado_en", new Date(Date.now() - 30 * 60 * 1000).toISOString());

  if ((recientes ?? 0) > 1) {
    return json({ ok: true, sent: 0, message: "Push reciente ya enviado" });
  }

  const ok = await sendFcm(
    token,
    "Tu alerta se está difundiendo",
    `Alguien compartió la búsqueda de ${alerta.nombre_persona} por WhatsApp.`,
    { alerta_id: body.alerta_id, tipo: "alerta_compartida" },
  );

  await registrarLog("info", "dispatch-share-push", ok ? "enviado" : "fallo", {
    alerta_id: body.alerta_id,
  });

  return json({ ok, sent: ok ? 1 : 0, total: 1 });
});

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
