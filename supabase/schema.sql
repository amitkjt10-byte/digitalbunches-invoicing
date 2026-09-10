-- Digital Bunches Invoicing — Supabase schema
-- Run this once in your Supabase project's SQL editor (Project > SQL Editor > New query).

create extension if not exists "pgcrypto";

-- One row per signed-up user, holding their whole invoicing workspace
-- (business profile, clients, invoices) as a JSON document.
create table if not exists app_data (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Row Level Security: every user can only ever read/write their own row.
alter table app_data enable row level security;

create policy "Users can read their own data"
  on app_data for select
  using (auth.uid() = user_id);

create policy "Users can insert their own data"
  on app_data for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own data"
  on app_data for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own data"
  on app_data for delete
  using (auth.uid() = user_id);

-- Keep updated_at current on every write.
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger app_data_set_updated_at
  before update on app_data
  for each row
  execute function set_updated_at();
