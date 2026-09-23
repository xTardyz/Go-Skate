// Gemeinsame Auth-Helfer. Setzt voraus, dass supabaseClient.js bereits geladen ist.

async function getCurrentUser() {
  const { data } = await window.sb.auth.getUser();
  return data.user || null;
}

/** Leitet auf login.html um, falls niemand eingeloggt ist. Gibt den User zurueck, falls ja. */
async function requireAuth() {
  const user = await getCurrentUser();
  if (!user) {
    window.location.href = "login.html";
    return null;
  }
  return user;
}

async function signOut() {
  await window.sb.auth.signOut();
  window.location.href = "login.html";
}
