import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { sendFcm } from "../_shared/fcm.ts";
import { registrarLog } from "../_shared/logging.ts";

interface DispatchBody {
  alerta_id: string;
  lat: number;
  lng: number;
  radio_km?: number;
  nombre_persona: string;
  edad_aprox?: number;
  ultima_vista_texto?: string;
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

  const { data: usuarios, error } = await supabase.rpc("usuarios_en_radio", {
    origen_lat: body.lat,
    origen_lng: body.lng,
    radio_metros: radioMetros,
    p_excluir_usuario_id: alerta?.emisor_id ?? null,
  });

  if (error) {
    await registrarLog("error", "dispatch-alert-push", "usuarios_en_radio", {
      alerta_id: body.alerta_id,
      error: error.message,
    });
    return json({ ok: false, error: error.message }, 500);
  }

  const edad = body.edad_aprox != null ? `, ~${body.edad_aprox} años` : "";
  const lugar = body.ultima_vista_texto?.trim();
  const lugarTexto = lugar ? `. Último lugar: ${truncate(lugar, 60)}` : "";
  const title = "Desaparición cerca de ti";
  const pushBody =
    `Buscamos a ${body.nombre_persona}${edad}${lugarTexto}. Radio: ${radioKm} km. Toca para ver.`;

  let sent = 0;
  for (const row of usuarios ?? []) {
    const token = row.fcm_token as string | null;
    if (!token) continue;

    const ok = await sendFcm(
      token,
      title,
      pushBody,
      { alerta_id: body.alerta_id, tipo: "alerta_nueva" },
    );
    if (ok) sent += 1;
  }

  await registrarLog("info", "dispatch-alert-push", "completado", {
    alerta_id: body.alerta_id,
    sent,
    total: usuarios?.length ?? 0,
  });

  return json({ ok: true, sent, total: usuarios?.length ?? 0 });
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
