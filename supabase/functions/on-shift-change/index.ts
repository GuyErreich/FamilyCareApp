import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import webpush from "npm:web-push@3";

interface ShiftRecord {
  id: string;
  family_id: string;
  assigned_member_id: string;
  shift_date: string;
  start_hour: number;
  start_minute: number;
  duration_minutes: number;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: ShiftRecord | null;
  old_record: ShiftRecord | null;
}

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const vapidPublic = Deno.env.get("VAPID_PUBLIC_KEY") ?? "";
const vapidPrivate = Deno.env.get("VAPID_PRIVATE_KEY") ?? "";
const vapidSubject = Deno.env.get("VAPID_SUBJECT") ?? "mailto:support@familycare.local";

if (vapidPublic && vapidPrivate) {
  webpush.setVapidDetails(vapidSubject, vapidPublic, vapidPrivate);
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const payload = (await req.json()) as WebhookPayload;
  if (payload.table !== "shifts") {
    return new Response(JSON.stringify({ skipped: true }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  if (!vapidPublic || !vapidPrivate) {
    return new Response(JSON.stringify({ push: "vapid not configured" }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const familyId =
    payload.record?.family_id ?? payload.old_record?.family_id ?? null;
  if (!familyId) {
    return new Response(JSON.stringify({ error: "no family" }), { status: 400 });
  }

  const { data: profiles } = await admin
    .from("profiles")
    .select("id")
    .eq("family_id", familyId);

  if (!profiles?.length) {
    return new Response(JSON.stringify({ sent: 0 }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  const userIds = profiles.map((p) => p.id);
  const { data: subs } = await admin
    .from("push_subscriptions")
    .select("*")
    .in("user_id", userIds);

  const { data: latestNotes } = await admin
    .from("notifications")
    .select("title, body, user_id")
    .in("user_id", userIds)
    .order("created_at", { ascending: false })
    .limit(userIds.length);

  const noteByUser = new Map(
    (latestNotes ?? []).map((n) => [n.user_id, n]),
  );

  let sent = 0;
  for (const sub of subs ?? []) {
    const note = noteByUser.get(sub.user_id);
    if (!note) continue;
    try {
      await webpush.sendNotification(
        {
          endpoint: sub.endpoint,
          keys: { p256dh: sub.p256dh, auth: sub.auth_key },
        },
        JSON.stringify({
          title: note.title,
          body: note.body,
        }),
      );
      sent += 1;
    } catch {
      // Expired subscription — best effort cleanup
      await admin.from("push_subscriptions").delete().eq("id", sub.id);
    }
  }

  return new Response(JSON.stringify({ sent }), {
    headers: { "Content-Type": "application/json" },
  });
});
