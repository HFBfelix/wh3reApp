-- Wh3re — Triggers automatiques + politiques RLS pour rejoindre un événement
-- À exécuter APRÈS 001_initial_schema.sql

-- ── Profil auto-créé à l'inscription (ne pas dupliquer côté Flutter) ─────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, first_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'Utilisateur')
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ── has_responded synchronisé à chaque soumission de réponse ─────────────────
CREATE OR REPLACE FUNCTION public.sync_member_has_responded()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.event_members
  SET has_responded = TRUE
  WHERE event_id = NEW.event_id
    AND user_id = NEW.user_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_response_submitted ON public.responses;
CREATE TRIGGER on_response_submitted
  AFTER INSERT OR UPDATE ON public.responses
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_member_has_responded();

-- ── Politique INSERT : rejoindre un événement en tant qu'invité ───────────────
CREATE POLICY "Users can join events as guest"
  ON public.event_members
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND role = 'guest'
    AND EXISTS (
      SELECT 1 FROM public.events e WHERE e.id = event_id
    )
  );

-- ── Lecture événement par token d'invitation (rejoindre via deep link) ───────
CREATE POLICY "Authenticated users can lookup events by invite token"
  ON public.events
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = creator_id
    OR auth.uid() IN (
      SELECT em.user_id FROM public.event_members em WHERE em.event_id = id
    )
    OR invite_token IS NOT NULL
  );

-- Permet à l'utilisateur de lire son propre profil (complément inscription)
CREATE POLICY "Users can insert own profile"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);
