const _defaultUrl = 'https://wukazkhhqvpmbakhnmrz.supabase.co';
const _defaultKey = 'sb_publishable_IZo4cg24GAMg8f-PKTRPmw_dMDzWaym';
const _envUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
const _envKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: '',
);

const supabaseUrl = _envUrl == '' ? _defaultUrl : _envUrl;
const supabasePublishableKey = _envKey == '' ? _defaultKey : _envKey;
