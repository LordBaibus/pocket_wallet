/// Supabase connection settings.
///
/// Locally you can paste values into the defaults below, or pass them:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
/// On Codemagic they come from environment variables (see codemagic.yaml).
///
/// Use the publishable key (sb_publishable_...), never the secret key.
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://YOUR-PROJECT-REF.supabase.co',
);
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_YOUR-KEY',
);
