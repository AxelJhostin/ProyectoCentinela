import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { sendFcm } from "../_shared/fcm.ts";
import { registrarLog } from "../_shared/logging.ts";

interface Body {
  alerta_id: string;
  lat: number;
  lng: number;
  radio_km?: number;
  nombre_persona: string;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  if (!Deno.env.get("FIREBASE_SERVICE_ACCOUNT") && !Deno.env.get("FCM_SERVER_KEY")) {
    return json({ ok: false, sent: 0, message: "FCM no configurado" });
  }

  const body = (await req.json()) as Body;
  const radioKm = body.radio_km ?? 10;
  const radioMetros = radioKm * 1000;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: alerta } = await supabase
    .from("alertas_desaparecidos")
    .select("emisor_id")
    .eq("id", body.alerta_id)
    .maybeSingle();

  const emisorId = alerta?.emisor_id as string | undefined;
  const tokens = new Set<string>();

  const { data: reacciones } = await supabase
    .from("reacciones_avistamientos")
    .select("testigo_id")
    .eq("alerta_id", body.alerta_id);

  for (const row of reacciones ?? []) {
    const testigoId = row.testigo_id as string;
    if (testigoId === emisorId) continue;
    const { data: u } = await supabase
      .from("usuarios")
      .select("fcm_token")
      .eq("id", testigoId)
      .maybeSingle();
    const token = u?.fcm_token as string | null;
    if (token) tokens.add(token);
  }

  const { data: usuarios, error } = await supabase.rpc("usuarios_en_radio", {
    origen_lat: body.lat,
    origen_lng: body.lng,
    radio_metros: radioMetros,
    p_excluir_usuario_id: emisorId ?? null,
  });

  if (error) {
    return json({ ok: false, error: error.message }, 500);
  }

  for (const row of usuarios ?? []) {
    const token = row.fcm_token as string | null;
    if (token) tokens.add(token);
  }

  const title = "Caso resuelto";
  const pushBody =
    `${body.nombre_persona} fue marcado como resuelto. Gracias por ayudar a la comunidad.`;

  let sent = 0;
  for (const token of tokens) {
    const ok = await sendFcm(
      token,
      title,
      pushBody,
      { alerta_id: body.alerta_id, tipo: "alerta_resuelta" },
    );
    if (ok) sent += 1;
  }

  await registrarLog("info", "dispatch-resuelto-push", "completado", {
    alerta_id: body.alerta_id,
    sent,
    total: tokens.size,
  });

  return json({ ok: true, sent, total: tokens.size });
});

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
