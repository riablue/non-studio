-- Run once in Supabase → SQL Editor
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

alter table public.inquiries enable row level security;

-- Visitors may submit, but never read, edit, or delete.
drop policy if exists "public can insert inquiries" on public.inquiries;
create policy "public can insert inquiries"
  on public.inquiries for insert
  to anon
  with check (char_length(name) between 1 and 200 and char_length(email) between 3 and 320 and coalesce(char_length(notes),0) <= 5000);
