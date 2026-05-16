-- Wh3re — Schéma initial Supabase (PostgreSQL 15 + PostGIS)
-- À exécuter dans l'éditeur SQL Supabase, dans cet ordre exact.

-- 1. Extension PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Profiles (complète auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 3. Events
CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  ambiance TEXT,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'polling', 'decided', 'archived')),
  invite_token TEXT UNIQUE DEFAULT encode(gen_random_bytes(16), 'hex'),
  final_place_id TEXT,
  final_place_name TEXT,
  final_place_address TEXT,
  final_place_location GEOGRAPHY(Point, 4326),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Creator has full access" ON public.events FOR ALL USING (auth.uid() = creator_id);
CREATE POLICY "Members can view their events" ON public.events FOR SELECT USING (
  auth.uid() IN (SELECT user_id FROM public.event_members WHERE event_id = id)
);

-- 4. Event Members
CREATE TABLE public.event_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'guest' CHECK (role IN ('creator', 'guest')),
  has_responded BOOLEAN DEFAULT FALSE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (event_id, user_id)
);
ALTER TABLE public.event_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Members can view co-members" ON public.event_members FOR SELECT USING (
  auth.uid() IN (SELECT user_id FROM public.event_members em WHERE em.event_id = event_id)
);

-- 5. Questions Template (questions configurables par le créateur)
CREATE TABLE public.questions_template (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  question_type TEXT NOT NULL CHECK (question_type IN ('lieu', 'ambiance', 'budget', 'date', 'custom')),
  question_label TEXT NOT NULL,
  options JSONB NOT NULL DEFAULT '[]',
  sort_order INTEGER DEFAULT 0
);
ALTER TABLE public.questions_template ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Creator manages questions" ON public.questions_template FOR ALL USING (
  auth.uid() IN (SELECT creator_id FROM public.events WHERE id = event_id)
);
CREATE POLICY "Members can view questions" ON public.questions_template FOR SELECT USING (
  auth.uid() IN (SELECT user_id FROM public.event_members WHERE event_id = event_id)
);

-- 6. Responses (JSONB pour flexibilité maximale)
CREATE TABLE public.responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  answers JSONB NOT NULL DEFAULT '{}',
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (event_id, user_id)
);
ALTER TABLE public.responses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own response" ON public.responses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Creator reads all responses" ON public.responses FOR SELECT USING (
  auth.uid() IN (SELECT creator_id FROM public.events WHERE id = event_id)
);

-- 7. Final Suggestions (résultats du moteur IA)
CREATE TABLE public.final_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  place_id TEXT NOT NULL,
  place_name TEXT NOT NULL,
  place_address TEXT NOT NULL,
  place_location GEOGRAPHY(Point, 4326),
  place_types TEXT[],
  match_score NUMERIC(5,2),
  match_rationale TEXT,
  rank INTEGER DEFAULT 1,
  is_selected BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.final_suggestions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Members can view suggestions" ON public.final_suggestions FOR SELECT USING (
  auth.uid() IN (SELECT user_id FROM public.event_members WHERE event_id = event_id)
);

-- 8. Trigger updated_at sur events
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;
CREATE TRIGGER events_updated_at BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 9. Seed data de démonstration (à supprimer en production)
-- À insérer après avoir créé un compte avec l'email test@wh3re.app
--
-- Exemple (adapter les UUID après création du compte) :
-- INSERT INTO public.profiles (id, first_name) VALUES ('<USER_UUID>', 'Test');
-- INSERT INTO public.events (creator_id, name, status) VALUES ('<USER_UUID>', 'Apéro équipe', 'draft');
