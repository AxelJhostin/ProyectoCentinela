import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface DispatchBody {
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

  const fcmKey = Deno.env.get("FCM_SERVER_KEY");
  if (!fcmKey) {
    return json({
      ok: false,
      sent: 0,
      message: "FCM_SERVER_KEY no configurada en Supabase Secrets",
    });
  }

  const body = (await req.json()) as DispatchBody;
  const radioKm = body.radio_km ?? 5;
  const radioMetros = radioKm * 1000;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: usuarios, error } = await supabase.rpc("usuarios_en_radio", {
    origen_lat: body.lat,
    origen_lng: body.lng,
    radio_metros: radioMetros,
  });

  if (error) {
    return json({ ok: false, error: error.message }, 500);
  }

  let sent = 0;
  for (const row of usuarios ?? []) {
    const token = row.fcm_token as string | null;
    if (!token) continue;

    const res = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        Authorization: `key=${fcmKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        to: token,
        priority: "high",
        notification: {
          title: "⚠️ Alerta de desaparición cerca de ti",
          body: `Buscamos a ${body.nombre_persona}. Toca para ver detalles.`,
        },
        data: {
          alerta_id: body.alerta_id,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      }),
    });

    if (res.ok) sent += 1;
  }

  return json({ ok: true, sent, total: usuarios?.length ?? 0 });
});

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
