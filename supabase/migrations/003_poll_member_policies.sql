-- Permet au créateur de s'insérer comme membre (upsert à la création d'événement)
CREATE POLICY "Creator can upsert own membership"
  ON public.event_members
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND role = 'creator'
    AND EXISTS (
      SELECT 1 FROM public.events e
      WHERE e.id = event_id AND e.creator_id = auth.uid()
    )
  );
