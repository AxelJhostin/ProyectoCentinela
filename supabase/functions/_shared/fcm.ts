import "jsr:@supabase/functions-js/edge-runtime.d.ts";

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

interface FcmData {
  [key: string]: string;
}

let cachedToken: { value: string; expiresAt: number } | null = null;

function base64UrlEncode(data: Uint8Array): string {
  return btoa(String.fromCharCode(...data))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

async function getAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.expiresAt > now + 60) {
    return cachedToken.value;
  }

  const header = base64UrlEncode(new TextEncoder().encode(JSON.stringify({
    alg: "RS256",
    typ: "JWT",
  })));

  const claim = base64UrlEncode(new TextEncoder().encode(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  })));

  const unsigned = `${header}.${claim}`;
  const keyData = sa.private_key.replace(/\\n/g, "\n");
  const pemContents = keyData
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsigned),
  );

  const jwt = `${unsigned}.${base64UrlEncode(new Uint8Array(signature))}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenRes.ok) {
    throw new Error(`OAuth token error: ${await tokenRes.text()}`);
  }

  const tokenJson = await tokenRes.json();
  cachedToken = {
    value: tokenJson.access_token,
    expiresAt: now + (tokenJson.expires_in ?? 3600),
  };
  return cachedToken.value;
}

export async function sendFcmV1(
  token: string,
  title: string,
  body: string,
  data: FcmData,
): Promise<boolean> {
  const saJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!saJson) return false;

  const sa = JSON.parse(saJson) as ServiceAccount;
  const accessToken = await getAccessToken(sa);

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
          android: { priority: "HIGH" },
        },
      }),
    },
  );

  return res.ok;
}

export async function sendFcmLegacy(
  token: string,
  title: string,
  body: string,
  data: FcmData,
): Promise<boolean> {
  const fcmKey = Deno.env.get("FCM_SERVER_KEY");
  if (!fcmKey) return false;

  const res = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      Authorization: `key=${fcmKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      to: token,
      priority: "high",
      notification: { title, body },
      data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
    }),
  });

  return res.ok;
}

export async function sendFcm(
  token: string,
  title: string,
  body: string,
  data: FcmData,
): Promise<boolean> {
  if (Deno.env.get("FIREBASE_SERVICE_ACCOUNT")) {
    return sendFcmV1(token, title, body, data);
  }
  return sendFcmLegacy(token, title, body, data);
}
