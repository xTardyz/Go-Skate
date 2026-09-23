# Skate App – statische HTML/JS/CSS-Version

Reines HTML/CSS/JavaScript, kein Build-Prozess. Laeuft direkt via GitHub Pages
(oder jedem anderen statischen Hosting). Backend/Realtime laeuft ueber
Supabase, angebunden per Supabase-JS-CDN.

## Setup

### 1. Supabase-Projekt anlegen

1. Neues Projekt auf [supabase.com](https://supabase.com) erstellen.
2. Im **SQL Editor** den Inhalt von `supabase/schema.sql` ausführen (Tabellen,
   RLS-Policies, Realtime-Aktivierung, Trick-Seed – alles in einer Datei).
3. Unter **Settings → API**: `Project URL` und `anon public` Key kopieren.

### 2. Konfiguration eintragen

`js/config.js` öffnen und die beiden Platzhalter ersetzen:

```js
window.SKATE_SUPABASE_URL = "https://dein-projekt.supabase.co";
window.SKATE_SUPABASE_ANON_KEY = "dein-anon-key";
```

Der `anon`-Key ist bewusst öffentlich (er landet im Frontend-Code) – die
eigentliche Absicherung übernimmt Row Level Security in der Datenbank.
**Niemals** den `service_role`-Key hier eintragen.

### 3. Lokal testen

Da es kein Build gibt, reicht ein simpler lokaler Server (wegen `fetch`/CORS
funktioniert `file://` in modernen Browsern oft nicht zuverlässig):

```bash
npx serve .
# oder
python3 -m http.server 8080
```

Dann `http://localhost:8080` öffnen.

### 4. GitHub Pages deployen

1. Repository auf GitHub erstellen, diesen Ordnerinhalt pushen.
2. **Settings → Pages** → Branch auswählen (z. B. `main`, Ordner `/root`).
3. Nach ein paar Minuten ist die Seite unter
   `https://<username>.github.io/<repo>/` erreichbar.

Da `js/config.js` die Supabase-Zugangsdaten enthält: entweder das Repo public
lassen (der `anon`-Key ist dafür gemacht) oder `config.js` vor dem Push in
`.gitignore` aufnehmen und stattdessen eine `config.example.js` committen,
falls das Repo privat bleiben soll.

## Seitenstruktur

```
index.html        Startseite
login.html         Anmelden
register.html      Registrieren
game.html          Game erstellen / Raum beitreten
lobby.html         Warteraum (Realtime, ?room=CODE)
play.html          Spielverlauf (Realtime, ?room=CODE)
result.html        Ergebnis + Trick-Verlauf (?room=CODE)
spots.html         Skate-Spots Übersicht
spot.html          Spot-Detail (?id=ID)
profile.html       Profil + Statistik
```

Gemeinsame Logik liegt in `js/`:

```
config.js          Supabase-Zugangsdaten (anpassen!)
supabaseClient.js   Erstellt den globalen Supabase-Client (window.sb)
gameLogic.js        Reine Spiellogik: Buchstabenvergabe, Gewinnerermittlung
tricksSearch.js      Trick-Filter/-Kategorien
auth.js              getCurrentUser / requireAuth / signOut
nav.js                Bottom-Navigation
```

`game_rounds` ist die Single Source of Truth für den Spielstand –
Buchstaben und Gewinner werden clientseitig aus dem Rundenverlauf berechnet
(`gameLogic.js`), nicht redundant gespeichert.

## Realtime-Prinzip

Beide Spieler abonnieren `postgres_changes` auf `game_rounds` (gefiltert nach
`game_id`). Sobald ein Zug eingetragen wird, aktualisiert sich der
Spielstand auf beiden Geräten automatisch, ohne Neuladen der Seite.

## Was bewusst fehlt (spätere Version)

- Interaktive Karte auf der Spots-Seite (DB ist mit `location_lat`/`location_lng`
  bereits vorbereitet)
- Trick-Favoriten, Trick-Statistiken, Challenges, Ranglisten
- Spiele mit mehr als 2 Spielern
