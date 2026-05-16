-- Politiques pour la décision du créateur sur les suggestions

CREATE POLICY "Creator updates event final place"
  ON public.events
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = creator_id)
  WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Creator updates suggestion selection"
  ON public.final_suggestions
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() IN (
      SELECT creator_id FROM public.events WHERE id = event_id
    )
  )
  WITH CHECK (
    auth.uid() IN (
      SELECT creator_id FROM public.events WHERE id = event_id
    )
  );
