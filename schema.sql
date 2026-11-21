-- =====================================================================
-- DATABASE APP GIOCATE (un solo utente, niente account)
-- La tabella non è leggibile con la chiave pubblica: si accede solo
-- tramite le funzioni qui sotto, che chiedono il codice di accesso.
-- =====================================================================

create extension if not exists pgcrypto with schema extensions;

create table public.giocate (
  giorno date primary key,
  puntata numeric(10,2) check (puntata >= 0),
  vincita numeric(10,2) check (vincita >= 0),
  ricarica numeric(10,2) check (ricarica >= 0),
  updated_at timestamptz not null default now()
);
alter table public.giocate enable row level security;
revoke all on public.giocate from anon, authenticated;

create schema giocate_private;
revoke all on schema giocate_private from public, anon, authenticated;
create table giocate_private.chiave (id int primary key default 1 check (id = 1), hash text not null);

create function giocate_private.verifica(p_codice text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if p_codice is null or not exists (
    select 1 from giocate_private.chiave c where c.hash = extensions.crypt(upper(trim(p_codice)), c.hash)
  ) then
    perform pg_sleep(1);
    raise exception 'codice non valido' using errcode = '28000';
  end if;
end $$;

-- elenco di tutte le giocate
create function public.giocate_elenco(p_codice text)
returns table (giorno date, puntata numeric, vincita numeric, ricarica numeric)
language plpgsql security definer set search_path = '' as $$
begin
  perform giocate_private.verifica(p_codice);
  return query select g.giorno, g.puntata, g.vincita, g.ricarica from public.giocate g order by g.giorno;
end $$;

-- salva più giorni insieme: [{"giorno":"2026-11-21","puntata":5,"vincita":null,"ricarica":10}, ...]
-- un giorno con tutti i valori vuoti viene cancellato
create function public.giocate_salva(p_codice text, p_giorni jsonb)
returns integer
language plpgsql security definer set search_path = '' as $$
declare n integer;
begin
  perform giocate_private.verifica(p_codice);
  delete from public.giocate g using jsonb_to_recordset(p_giorni) as x(giorno date, puntata numeric, vincita numeric, ricarica numeric)
    where g.giorno = x.giorno and x.puntata is null and x.vincita is null and x.ricarica is null;
  insert into public.giocate (giorno, puntata, vincita, ricarica, updated_at)
    select x.giorno, round(x.puntata, 2), round(x.vincita, 2), round(x.ricarica, 2), now()
    from jsonb_to_recordset(p_giorni) as x(giorno date, puntata numeric, vincita numeric, ricarica numeric)
    where x.puntata is not null or x.vincita is not null or x.ricarica is not null
    on conflict (giorno) do update set puntata = excluded.puntata, vincita = excluded.vincita,
      ricarica = excluded.ricarica, updated_at = now();
  get diagnostics n = row_count;
  return n;
end $$;

revoke all on function giocate_private.verifica(text) from public, anon, authenticated;
revoke all on function public.giocate_elenco(text) from public;
revoke all on function public.giocate_salva(text, jsonb) from public;
grant execute on function public.giocate_elenco(text) to anon;
grant execute on function public.giocate_salva(text, jsonb) to anon;
