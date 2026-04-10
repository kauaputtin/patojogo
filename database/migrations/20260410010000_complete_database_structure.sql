-- =========================================
-- PatoJogo - Estrutura Completa do Banco
-- =========================================
-- Esta migration cria todas as tabelas necessárias para o sistema PatoJogo
-- Incluindo: perfis, progresso do quiz, tentativas e políticas de segurança

-- =========================================
-- 1. TABELA DE PERFIS DE USUÁRIO
-- =========================================
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  full_name text not null,
  phone text not null unique check (phone ~ '^[0-9]{10,11}$'),
  progress_step integer not null default 0 check (progress_step >= 0),
  score integer not null default 0 check (score >= 0),
  coins integer not null default 0 check (coins >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- =========================================
-- 2. TABELA DE PROGRESSO DO QUIZ
-- =========================================
create table if not exists public.quiz_progress (
  user_id uuid primary key references auth.users (id) on delete cascade,
  unlocked_levels text[] not null default array['beginner']::text[],
  level_progress jsonb not null default '{
    "beginner": {
      "averageAccuracy": 0,
      "bestScore": 0,
      "categoryStats": {},
      "completedCount": 0,
      "completedQuestions": [],
      "completionPercentage": 0,
      "correctCount": 0,
      "incorrectCount": 0,
      "lastAttemptDate": null,
      "skippedCount": 0,
      "totalCoins": 0,
      "totalQuestions": 0,
      "totalScore": 0
    },
    "intermediate": {
      "averageAccuracy": 0,
      "bestScore": 0,
      "categoryStats": {},
      "completedCount": 0,
      "completedQuestions": [],
      "completionPercentage": 0,
      "correctCount": 0,
      "incorrectCount": 0,
      "lastAttemptDate": null,
      "skippedCount": 0,
      "totalCoins": 0,
      "totalQuestions": 0,
      "totalScore": 0
    },
    "advanced": {
      "averageAccuracy": 0,
      "bestScore": 0,
      "categoryStats": {},
      "completedCount": 0,
      "completedQuestions": [],
      "completionPercentage": 0,
      "correctCount": 0,
      "incorrectCount": 0,
      "lastAttemptDate": null,
      "skippedCount": 0,
      "totalCoins": 0,
      "totalQuestions": 0,
      "totalScore": 0
    }
  }'::jsonb,
  achievements jsonb not null default '[]'::jsonb,
  total_points integer not null default 0 check (total_points >= 0),
  total_coins integer not null default 0 check (total_coins >= 0),
  completed_quiz_count integer not null default 0 check (completed_quiz_count >= 0),
  last_synced_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- =========================================
-- 3. TABELA DE TENTATIVAS DO QUIZ
-- =========================================
create table if not exists public.quiz_attempts (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  level text not null check (level in ('beginner', 'intermediate', 'advanced')),
  answers jsonb not null default '[]'::jsonb,
  summary jsonb not null default '{
    "accuracy": 0,
    "correctCount": 0,
    "incorrectCount": 0,
    "skippedCount": 0,
    "totalTimeInSeconds": 0,
    "timePerQuestion": 0,
    "totalQuestions": 0,
    "stars": 0
  }'::jsonb,
  total_score integer not null default 0 check (total_score >= 0),
  total_coins integer not null default 0 check (total_coins >= 0),
  status text not null default 'completed' check (status in ('completed', 'abandoned')),
  started_at timestamptz not null default timezone('utc', now()),
  completed_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- =========================================
-- 4. TABELA DE LOJA (OPCIONAL - PARA FUTURO)
-- =========================================
create table if not exists public.store_items (
  id text primary key,
  name text not null,
  description text not null,
  price_coins integer not null check (price_coins >= 0),
  category text not null check (category in ('avatar', 'theme', 'powerup', 'cosmetic')),
  image_url text,
  is_available boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  item_id text not null references public.store_items (id) on delete cascade,
  purchased_at timestamptz not null default timezone('utc', now()),
  unique(user_id, item_id)
);

-- =========================================
-- 5. ÍNDICES PARA PERFORMANCE
-- =========================================
create index if not exists profiles_score_idx on public.profiles (score desc);
create index if not exists profiles_progress_step_idx on public.profiles (progress_step);
create index if not exists quiz_attempts_user_id_idx on public.quiz_attempts (user_id);
create index if not exists quiz_attempts_user_level_completed_idx on public.quiz_attempts (user_id, level, completed_at desc);
create index if not exists quiz_progress_total_points_idx on public.quiz_progress (total_points desc);

-- =========================================
-- 6. FUNÇÕES ÚTEIS
-- =========================================

-- Função para atualizar automaticamente o score e coins do perfil
create or replace function public.handle_quiz_progress_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set
    score = greatest(coalesce(new.total_points, 0), 0),
    coins = greatest(coalesce(new.total_coins, 0), 0),
    progress_step = greatest(coalesce(progress_step, 0), coalesce(new.completed_quiz_count, 0)),
    updated_at = timezone('utc', now())
  where id = new.user_id;

  return new;
end;
$$;

-- Função para criar perfil automaticamente quando usuário se registra
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_phone text;
begin
  normalized_phone := regexp_replace(
    coalesce(new.raw_user_meta_data ->> 'phone', ''),
    '\D',
    '',
    'g'
  );

  insert into public.profiles (
    id,
    email,
    full_name,
    phone
  )
  values (
    new.id,
    new.email,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
      split_part(new.email, '@', 1)
    ),
    normalized_phone
  );

  -- Criar progresso inicial do quiz
  insert into public.quiz_progress (user_id)
  values (new.id);

  return new;
end;
$$;

-- Função para atualizar updated_at automaticamente
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

-- =========================================
-- 7. TRIGGERS
-- =========================================
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

drop trigger if exists quiz_progress_updated on public.quiz_progress;
create trigger quiz_progress_updated
  after insert or update on public.quiz_progress
  for each row execute procedure public.handle_quiz_progress_change();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();

drop trigger if exists quiz_progress_set_updated_at on public.quiz_progress;
create trigger quiz_progress_set_updated_at
  before update on public.quiz_progress
  for each row execute procedure public.set_updated_at();

drop trigger if exists quiz_attempts_set_updated_at on public.quiz_attempts;
create trigger quiz_attempts_set_updated_at
  before update on public.quiz_attempts
  for each row execute procedure public.set_updated_at();

drop trigger if exists store_items_set_updated_at on public.store_items;
create trigger store_items_set_updated_at
  before update on public.store_items
  for each row execute procedure public.set_updated_at();

-- =========================================
-- 8. ROW LEVEL SECURITY (RLS)
-- =========================================
alter table public.profiles enable row level security;
alter table public.quiz_progress enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.store_items enable row level security;
alter table public.user_purchases enable row level security;

-- Políticas para profiles
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "profiles_select_all_public" on public.profiles;
create policy "profiles_select_all_public"
  on public.profiles
  for select
  to authenticated
  using (true);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles
  for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Políticas para quiz_progress
drop policy if exists "quiz_progress_select_own" on public.quiz_progress;
create policy "quiz_progress_select_own"
  on public.quiz_progress
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "quiz_progress_insert_own" on public.quiz_progress;
create policy "quiz_progress_insert_own"
  on public.quiz_progress
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "quiz_progress_update_own" on public.quiz_progress;
create policy "quiz_progress_update_own"
  on public.quiz_progress
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Políticas para quiz_attempts
drop policy if exists "quiz_attempts_select_own" on public.quiz_attempts;
create policy "quiz_attempts_select_own"
  on public.quiz_attempts
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "quiz_attempts_insert_own" on public.quiz_attempts;
create policy "quiz_attempts_insert_own"
  on public.quiz_attempts
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Políticas para store_items (público para leitura)
drop policy if exists "store_items_select_all" on public.store_items;
create policy "store_items_select_all"
  on public.store_items
  for select
  to authenticated
  using (true);

-- Políticas para user_purchases
drop policy if exists "user_purchases_select_own" on public.user_purchases;
create policy "user_purchases_select_own"
  on public.user_purchases
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "user_purchases_insert_own" on public.user_purchases;
create policy "user_purchases_insert_own"
  on public.user_purchases
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- =========================================
-- 9. DADOS INICIAIS (SEED)
-- =========================================

-- Itens da loja inicial
insert into public.store_items (id, name, description, price_coins, category, image_url) values
  ('avatar-pato-dourado', 'Pato Dourado', 'Avatar especial do Pato Dourado', 500, 'avatar', '/avatars/pato-dourado.png'),
  ('theme-noite', 'Tema Noturno', 'Interface com cores escuras', 300, 'theme', '/themes/noite.png'),
  ('powerup-dica-extra', 'Dica Extra', 'Receba uma dica adicional por pergunta', 100, 'powerup', '/powerups/dica-extra.png'),
  ('cosmetic-borda-dourada', 'Borda Dourada', 'Borda dourada no perfil', 250, 'cosmetic', '/cosmetics/borda-dourada.png')
on conflict (id) do nothing;

-- =========================================
-- MIGRATION COMPLETA - APLICAR NO SUPABASE
-- =========================================