// Benoetigt das Supabase-CDN-Skript (siehe <head> jeder Seite), das den
// globalen "supabase"-Namespace mit createClient() bereitstellt.
window.sb = window.supabase.createClient(
  window.SKATE_SUPABASE_URL,
  window.SKATE_SUPABASE_ANON_KEY
);
