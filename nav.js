function renderBottomNav() {
  const current = window.location.pathname.split("/").pop() || "index.html";
  const items = [
    { href: "index.html", label: "Home", icon: "🏠" },
    { href: "game.html", label: "Game", icon: "🎮" },
    { href: "spots.html", label: "Spots", icon: "📍" },
    { href: "profile.html", label: "Profil", icon: "👤" },
  ];

  const isActive = (href) => {
    if (href === "game.html") {
      return ["game.html", "lobby.html", "play.html", "result.html"].includes(current);
    }
    if (href === "spots.html") {
      return ["spots.html", "spot.html"].includes(current);
    }
    return current === href;
  };

  const html = `
    <div class="row">
      ${items
        .map(
          (item) => `
        <a href="${item.href}" class="${isActive(item.href) ? "active" : ""}">
          <span class="icon">${item.icon}</span>${item.label}
        </a>`
        )
        .join("")}
    </div>`;

  const el = document.createElement("nav");
  el.className = "bottom-nav";
  el.innerHTML = html;
  document.body.appendChild(el);
}

document.addEventListener("DOMContentLoaded", renderBottomNav);
