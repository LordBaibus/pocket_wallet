-- Pocket Wallet schema. Run this in Supabase Dashboard > SQL Editor.

create table if not exists public.cards (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  label       text not null,
  number      text not null,
  color       text not null default '#5B5BD6',
  created_at  timestamptz not null default now()
);

create index if not exists cards_user_id_idx on public.cards (user_id);

alter table public.cards enable row level security;

create policy "cards_select_own" on public.cards
  for select to authenticated using (user_id = auth.uid());

create policy "cards_insert_own" on public.cards
  for insert to authenticated with check (user_id = auth.uid());

create policy "cards_update_own" on public.cards
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "cards_delete_own" on public.cards
  for delete to authenticated using (user_id = auth.uid());
