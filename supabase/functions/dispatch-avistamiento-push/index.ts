import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { sendFcm } from "../_shared/fcm.ts";
import { registrarLog } from "../_shared/logging.ts";

interface Body {
  alerta_id: string;
  ubicacion_texto?: string;
  distancia_km?: number;
  nota_preview?: string;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  if (!Deno.env.get("FIREBASE_SERVICE_ACCOUNT") && !Deno.env.get("FCM_SERVER_KEY")) {
    return json({ ok: false, message: "FCM no configurado en Supabase Secrets" });
  }

  const body = (await req.json()) as Body;
  const { alerta_id } = body;

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

  const lugar = body.ubicacion_texto?.trim();
  const dist = body.distancia_km != null
    ? `${body.distancia_km.toFixed(1)} km de tu reporte`
    : null;
  const nota = body.nota_preview?.trim();

  let detalle = "Alguien reportó haberlo visto.";
  if (lugar && dist) {
    detalle = `Visto cerca de ${truncate(lugar, 50)} (${dist}).`;
  } else if (lugar) {
    detalle = `Visto cerca de ${truncate(lugar, 60)}.`;
  } else if (dist) {
    detalle = `Avistamiento a ${dist}.`;
  }
  if (nota) {
    detalle += ` Nota: ${truncate(nota, 80)}`;
  }

  const ok = await sendFcm(
    token,
    "👁 Nuevo avistamiento",
    `${detalle} ${alerta.nombre_persona}.`,
    { alerta_id, tipo: "avistamiento" },
  );

  await registrarLog("info", "dispatch-avistamiento-push", ok ? "enviado" : "fallo", {
    alerta_id,
  });

  return json({ ok, sent: ok ? 1 : 0 });
});

function truncate(text: string, max: number): string {
  if (text.length <= max) return text;
  return `${text.slice(0, max - 1)}…`;
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
