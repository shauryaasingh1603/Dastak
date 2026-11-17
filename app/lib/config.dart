/// Backend the app talks to. Both values are public by design: access is
/// decided by row-level security on the server, not by this key.
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://sxqydhyavbximzjwqibm.supabase.co',
);

const supabaseKey = String.fromEnvironment(
  'SUPABASE_KEY',
  defaultValue: 'sb_publishable_aVz6xQzjA-jMiKWkFwi-iA_o7rW3FEJ',
);

/// How often the waiting screen asks whether the admin has decided.
const loginPollInterval = Duration(seconds: 4);
