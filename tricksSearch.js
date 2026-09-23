const TRICK_CATEGORIES = [
  { id: "flip", name: "Flip Tricks" },
  { id: "shuvit", name: "Shuvits" },
  { id: "spin", name: "Spins" },
  { id: "grind", name: "Grinds" },
  { id: "slide", name: "Slides" },
  { id: "manual", name: "Manuals" },
  { id: "grab", name: "Grabs" },
  { id: "freestyle", name: "Freestyle" },
  { id: "other", name: "Other" },
];

function categoryName(categoryId) {
  const found = TRICK_CATEGORIES.find((c) => c.id === categoryId);
  return found ? found.name : categoryId;
}

function filterTricks(tricks, query, categoryId) {
  let list = tricks;
  if (categoryId) list = list.filter((t) => t.category === categoryId);
  const q = (query || "").trim().toLowerCase();
  if (q) {
    list = list.filter(
      (t) =>
        t.name.toLowerCase().includes(q) ||
        (t.aliases || []).some((a) => a.toLowerCase().includes(q))
    );
  }
  return list;
}
