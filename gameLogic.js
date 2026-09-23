// Reine Spiellogik, unabhaengig von UI und Supabase - einfach testbar.

const MODE_WORDS = { SKATE: "SKATE", SK8: "SK8" };

function getModeWord(mode) {
  return MODE_WORDS[mode];
}

/**
 * Berechnet den aktuellen Spielstand rein aus dem Rundenverlauf.
 * game_rounds ist die Single Source of Truth - kein redundanter Zaehler,
 * der aus dem Realtime-Sync laufen koennte.
 */
function getGameStatus(rounds, mode, playerIds) {
  const word = getModeWord(mode);
  const counts = { [playerIds[0]]: 0, [playerIds[1]]: 0 };

  const sorted = [...rounds].sort((a, b) => a.round_number - b.round_number);

  for (const round of sorted) {
    if (round.result === "missed") {
      counts[round.defender_id] = (counts[round.defender_id] || 0) + 1;
      if (counts[round.defender_id] >= word.length) {
        const winnerId = playerIds.find((id) => id !== round.defender_id);
        return { status: "finished", letterCounts: counts, winnerId, loserId: round.defender_id };
      }
    }
  }

  return { status: "active", letterCounts: counts, winnerId: null, loserId: null };
}

/**
 * Ermittelt, wer die naechste Runde als "Setter" eroeffnet.
 * Regel: schafft der Verteidiger den Trick, uebernimmt er die Kontrolle.
 * Scheitert er, behaelt der bisherige Setter die Kontrolle.
 */
function getNextSetter(lastRound, fallbackFirstPlayerId) {
  if (!lastRound) return fallbackFirstPlayerId;
  return lastRound.result === "made" ? lastRound.defender_id : lastRound.setter_id;
}

function generateRoomCode() {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // ohne leicht verwechselbare Zeichen
  let code = "";
  for (let i = 0; i < 5; i++) code += chars[Math.floor(Math.random() * chars.length)];
  return code;
}
