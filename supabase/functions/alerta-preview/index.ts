import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const RESOLVED_IMAGE =
  "https://wziwufumjtpjqyuzzzyn.supabase.co/storage/v1/object/public/centinela-fotos/assets/caso-resuelto.png";

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const id = url.searchParams.get("id");

  if (!id) {
    return new Response("Falta parámetro id", { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data, error } = await supabase
    .from("alertas_desaparecidos")
    .select("id, nombre_persona, edad_aprox, vestimenta, foto_url, estado")
    .eq("id", id)
    .maybeSingle();

  if (error || !data) {
    return new Response(html("Alerta no encontrada", "Este enlace ya no es válido.", ""), {
      headers: { "Content-Type": "text/html; charset=utf-8" },
    });
  }

  const resuelta = data.estado !== "ACTIVA";
  const title = resuelta
    ? "✅ CASO RESUELTO"
    : `🚨 ALERTA: Buscamos a ${data.nombre_persona}`;
  const description = resuelta
    ? "Este caso fue marcado como resuelto. Gracias por tu apoyo."
    : `Desapareció (${data.edad_aprox} años). Toca para ver detalles y ayudar.`;
  const image = resuelta ? RESOLVED_IMAGE : data.foto_url;

  const bodyHtml = resuelta
    ? `<p>Este caso fue cerrado por la familia.</p>`
    : `<p><strong>${escapeHtml(data.nombre_persona)}</strong>, ${data.edad_aprox} años.</p>
       <p>${escapeHtml(data.vestimenta ?? "")}</p>
       <p>Abre la app Centinela para reportar si lo has visto.</p>`;

  return new Response(html(title, description, image, bodyHtml), {
    headers: { "Content-Type": "text/html; charset=utf-8" },
  });
});

function escapeHtml(text: string): string {
  return text
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function html(
  title: string,
  description: string,
  image: string,
  body = "",
): string {
  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>${escapeHtml(title)}</title>
  <meta property="og:title" content="${escapeHtml(title)}"/>
  <meta property="og:description" content="${escapeHtml(description)}"/>
  <meta property="og:image" content="${escapeHtml(image)}"/>
  <meta property="og:type" content="website"/>
  <style>
    body{font-family:system-ui,sans-serif;max-width:480px;margin:2rem auto;padding:0 1rem;color:#111827}
    img{max-width:100%;border-radius:12px}
    h1{color:#dc2626}
  </style>
</head>
<body>
  <h1>${escapeHtml(title)}</h1>
  ${image ? `<img src="${escapeHtml(image)}" alt=""/>` : ""}
  ${body}
</body>
</html>`;
}
