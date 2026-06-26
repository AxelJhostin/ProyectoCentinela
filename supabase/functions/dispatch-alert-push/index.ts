import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { sendFcm } from "../_shared/fcm.ts";

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

  if (!Deno.env.get("FIREBASE_SERVICE_ACCOUNT") && !Deno.env.get("FCM_SERVER_KEY")) {
    return json({
      ok: false,
      sent: 0,
      message: "Configura FIREBASE_SERVICE_ACCOUNT o FCM_SERVER_KEY en Supabase Secrets",
    });
  }

  const body = (await req.json()) as DispatchBody;
  const radioKm = body.radio_km ?? 5;
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

  const { data: usuarios, error } = await supabase.rpc("usuarios_en_radio", {
    origen_lat: body.lat,
    origen_lng: body.lng,
    radio_metros: radioMetros,
    p_excluir_usuario_id: alerta?.emisor_id ?? null,
  });

  if (error) {
    return json({ ok: false, error: error.message }, 500);
  }

  let sent = 0;
  for (const row of usuarios ?? []) {
    const token = row.fcm_token as string | null;
    if (!token) continue;

    const ok = await sendFcm(
      token,
      "⚠️ Alerta de desaparición cerca de ti",
      `Buscamos a ${body.nombre_persona}. Toca para ver detalles.`,
      { alerta_id: body.alerta_id, tipo: "alerta_nueva" },
    );
    if (ok) sent += 1;
  }

  return json({ ok: true, sent, total: usuarios?.length ?? 0 });
});

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
