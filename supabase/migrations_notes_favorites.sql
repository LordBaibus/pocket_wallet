-- Run once in the Supabase SQL Editor (adds notes + favorites to cards).
alter table public.cards add column if not exists notes text not null default '';
alter table public.cards add column if not exists is_favorite boolean not null default false;
notify pgrst, 'reload schema';
