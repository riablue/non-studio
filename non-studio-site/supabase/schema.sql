-- NON STUDIO · Supabase setup
-- Paste this whole file into Supabase → SQL Editor and click Run.
-- Safe to run again; every statement is idempotent.

-- 1. Booking inquiries ------------------------------------------------------
create table if not exists public.inquiries (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  form_no text,
  name text not null,
  email text not null,
  shoot text,
  shoot_date date,
  flexible_date boolean default false,
  city text,
  location text,
  delivery text,
  notes text
);
alter table public.inquiries add column if not exists status text not null default 'new';
alter table public.inquiries enable row level security;

-- 2. Admin allow-list -------------------------------------------------------
create table if not exists public.admins (email text primary key);
alter table public.admins enable row level security;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;

-- 3. Editable site content (photos + text) ----------------------------------
create table if not exists public.site_content (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);
alter table public.site_content enable row level security;

-- 4. Policies ---------------------------------------------------------------
drop policy if exists "public can insert inquiries" on public.inquiries;
create policy "public can insert inquiries" on public.inquiries for insert to anon, authenticated
  with check (char_length(name) between 1 and 200 and char_length(email) between 3 and 320 and coalesce(char_length(notes), 0) <= 5000);

drop policy if exists "admin reads inquiries" on public.inquiries;
create policy "admin reads inquiries" on public.inquiries for select to authenticated using (public.is_admin());
drop policy if exists "admin updates inquiries" on public.inquiries;
create policy "admin updates inquiries" on public.inquiries for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admin deletes inquiries" on public.inquiries;
create policy "admin deletes inquiries" on public.inquiries for delete to authenticated using (public.is_admin());

drop policy if exists "anyone reads content" on public.site_content;
create policy "anyone reads content" on public.site_content for select to anon, authenticated using (true);
drop policy if exists "admin writes content" on public.site_content;
create policy "admin writes content" on public.site_content for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- 5. Photo storage (public bucket "site") ------------------------------------
insert into storage.buckets (id, name, public) values ('site', 'site', true)
  on conflict (id) do update set public = true;

drop policy if exists "admin uploads photos" on storage.objects;
create policy "admin uploads photos" on storage.objects for insert to authenticated with check (bucket_id = 'site' and public.is_admin());
drop policy if exists "admin updates photos" on storage.objects;
create policy "admin updates photos" on storage.objects for update to authenticated using (bucket_id = 'site' and public.is_admin());
drop policy if exists "admin deletes photos" on storage.objects;
create policy "admin deletes photos" on storage.objects for delete to authenticated using (bucket_id = 'site' and public.is_admin());

-- 6. Add yourself as admin (replace with your login email) -------------------
insert into public.admins (email) values ('riablue.collab@gmail.com') on conflict do nothing;
