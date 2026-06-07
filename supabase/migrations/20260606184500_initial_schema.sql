create extension if not exists pgcrypto with schema extensions;
create extension if not exists vector with schema extensions;

create type public.study_mode as enum ('light', 'normal', 'strict');
create type public.study_method as enum ('visual', 'audio', 'writing', 'mixed');
create type public.plan_tier as enum ('free', 'premium');
create type public.session_status as enum ('draft', 'active', 'completed', 'failed', 'cancelled');
create type public.unlock_status as enum ('locked', 'pending_quiz', 'unlocked', 'failed');
create type public.study_asset_type as enum (
  'summary',
  'flashcards',
  'comparison_table',
  'mind_map',
  'audio_script',
  'writing_prompt',
  'mixed_path'
);
create type public.question_type as enum (
  'multiple_choice',
  'true_false',
  'short_answer',
  'argumentative',
  'mixed'
);
create type public.question_difficulty as enum ('easy', 'medium', 'hard');

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null,
  email text not null,
  daily_goal_minutes integer not null default 30 check (daily_goal_minutes > 0),
  preferred_mode public.study_mode not null default 'normal',
  preferred_method public.study_method not null default 'visual',
  plan_tier public.plan_tier not null default 'free',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.study_materials (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  file_type text not null,
  file_url text,
  extracted_text text,
  embedding extensions.vector(1536),
  analysis_status text not null default 'pending',
  created_at timestamptz not null default now()
);

create table public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  topic text not null,
  duration_minutes integer not null check (duration_minutes > 0),
  mode public.study_mode not null default 'normal',
  study_method public.study_method not null default 'visual',
  started_at timestamptz,
  ended_at timestamptz,
  status public.session_status not null default 'draft',
  score numeric(5, 2),
  unlock_status public.unlock_status not null default 'locked',
  created_at timestamptz not null default now()
);

create table public.session_materials (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.study_sessions (id) on delete cascade,
  material_id uuid not null references public.study_materials (id) on delete cascade,
  unique (session_id, material_id)
);

create table public.study_assets (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.study_sessions (id) on delete cascade,
  material_id uuid references public.study_materials (id) on delete set null,
  asset_type public.study_asset_type not null,
  title text not null,
  content jsonb not null default '{}'::jsonb,
  order_index integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.study_sessions (id) on delete cascade,
  question_text text not null,
  question_type public.question_type not null,
  options jsonb not null default '[]'::jsonb,
  correct_answer text not null,
  explanation text not null,
  difficulty public.question_difficulty not null default 'medium',
  related_concepts text[] not null default '{}',
  source_hint text,
  created_at timestamptz not null default now()
);

create table public.user_answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  answer_text text not null,
  is_correct boolean not null,
  score numeric(4, 3) not null check (score >= 0 and score <= 1),
  feedback text not null,
  created_at timestamptz not null default now()
);

create table public.blocked_apps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  app_name text not null,
  package_name text not null,
  default_blocked boolean not null default true,
  created_at timestamptz not null default now(),
  unique (user_id, package_name)
);

create table public.achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  achievement_name text not null,
  description text not null,
  unlocked_at timestamptz not null default now(),
  unique (user_id, achievement_name)
);

create table public.premium_limits (
  plan_tier public.plan_tier primary key,
  daily_sessions integer,
  files_per_session integer,
  max_session_minutes integer,
  supports_audio boolean not null default false,
  supports_mixed_mode boolean not null default false,
  supports_argumentative_feedback boolean not null default false
);

insert into public.premium_limits (
  plan_tier,
  daily_sessions,
  files_per_session,
  max_session_minutes,
  supports_audio,
  supports_mixed_mode,
  supports_argumentative_feedback
) values
  ('free', 2, 2, 60, false, false, false),
  ('premium', null, null, null, true, true, true);

alter table public.profiles enable row level security;
alter table public.study_materials enable row level security;
alter table public.study_sessions enable row level security;
alter table public.session_materials enable row level security;
alter table public.study_assets enable row level security;
alter table public.questions enable row level security;
alter table public.user_answers enable row level security;
alter table public.blocked_apps enable row level security;
alter table public.achievements enable row level security;
alter table public.premium_limits enable row level security;

create policy "profiles are readable by owner"
on public.profiles for select
using (auth.uid() = id);

create policy "profiles are insertable by owner"
on public.profiles for insert
with check (auth.uid() = id);

create policy "profiles are updatable by owner"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "materials belong to owner"
on public.study_materials for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "sessions belong to owner"
on public.study_sessions for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "session materials belong to session owner"
on public.session_materials for all
using (
  exists (
    select 1 from public.study_sessions
    where study_sessions.id = session_materials.session_id
      and study_sessions.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.study_sessions
    where study_sessions.id = session_materials.session_id
      and study_sessions.user_id = auth.uid()
  )
);

create policy "study assets belong to session owner"
on public.study_assets for all
using (
  exists (
    select 1 from public.study_sessions
    where study_sessions.id = study_assets.session_id
      and study_sessions.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.study_sessions
    where study_sessions.id = study_assets.session_id
      and study_sessions.user_id = auth.uid()
  )
);

create policy "questions belong to session owner"
on public.questions for all
using (
  exists (
    select 1 from public.study_sessions
    where study_sessions.id = questions.session_id
      and study_sessions.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.study_sessions
    where study_sessions.id = questions.session_id
      and study_sessions.user_id = auth.uid()
  )
);

create policy "answers belong to owner"
on public.user_answers for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "blocked apps belong to owner"
on public.blocked_apps for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "achievements belong to owner"
on public.achievements for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "premium limits are readable by authenticated users"
on public.premium_limits for select
to authenticated
using (true);
