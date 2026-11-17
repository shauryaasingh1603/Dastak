-- STATUS: not yet applied to the hosted project. Supabase asks the project owner
-- to confirm it (it drops and recreates policies) and that is still pending.
-- Remove this note once it has been applied.
--
-- Child rows follow their parent family. Written as "in (visible parents)" so
-- the set of visible parents is worked out once per query, not once per row.
drop policy scoped_read on public.voters;
create policy scoped_read on public.voters for select to authenticated
  using (family_id in (select f.id from public.families f));

drop policy scoped_read on public.visits;
create policy scoped_read on public.visits for select to authenticated
  using (family_id in (select f.id from public.families f));

drop policy scoped_read on public.visit_voters;
create policy scoped_read on public.visit_voters for select to authenticated
  using (visit_id in (select v.id from public.visits v));

drop policy scoped_read on public.forms;
create policy scoped_read on public.forms for select to authenticated
  using (voter_id in (select v.id from public.voters v));

drop policy scoped_read on public.form_events;
create policy scoped_read on public.form_events for select to authenticated
  using (form_id in (select f.id from public.forms f));
