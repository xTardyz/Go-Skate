// Trage hier deine Supabase-Projektdaten ein (Supabase Dashboard -> Settings -> API).
// Der "anon public" Key ist bewusst oeffentlich und darf im Frontend stehen -
// die eigentliche Absicherung passiert ueber Row Level Security (siehe supabase/schema.sql).
// NIEMALS den "service_role" Key hier eintragen oder committen!
window.SKATE_SUPABASE_URL = "https://your-project.supabase.co";
window.SKATE_SUPABASE_ANON_KEY = "your-anon-key";
