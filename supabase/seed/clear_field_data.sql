-- Empties the visit list and everything recorded against it. Users, booths and
-- the audit log are kept. Use it to remove mock data before the real import.
-- This cannot be undone: take a backup first if any real visits exist.
truncate public.form_events, public.forms, public.visit_voters, public.visits,
         public.voters, public.families;
