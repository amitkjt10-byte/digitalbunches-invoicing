import { supabase } from "./supabaseClient";

/**
 * All of a user's invoicing data (profile, clients, invoices) is stored as a
 * single JSONB document per user in the `app_data` table. This keeps the
 * data model simple for an MVP while still being backed by a real Postgres
 * database with per-user row-level security (see supabase/schema.sql).
 *
 * If you outgrow this later (e.g. you want to query/report across
 * invoices in SQL), split `invoices` and `clients` into their own tables —
 * the shape of the JSON here maps directly onto reasonable table columns.
 */

export async function loadAppData(userId) {
  const { data: row, error } = await supabase
    .from("app_data")
    .select("data")
    .eq("user_id", userId)
    .maybeSingle();

  if (error) throw error;
  return row ? row.data : null;
}

export async function createAppData(userId, data) {
  const { error } = await supabase
    .from("app_data")
    .insert({ user_id: userId, data });
  if (error) throw error;
}

export async function saveAppData(userId, data) {
  const { error } = await supabase
    .from("app_data")
    .upsert(
      { user_id: userId, data, updated_at: new Date().toISOString() },
      { onConflict: "user_id" }
    );
  if (error) throw error;
}
