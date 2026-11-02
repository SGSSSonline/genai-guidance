document.addEventListener("DOMContentLoaded", () => {
  const sidebar = document.querySelector("#quarto-sidebar.docked");
  if (!sidebar) return;

  for (const group of sidebar.querySelectorAll(
    ".sidebar-menu-container > ul > .sidebar-item-section",
  )) {
    const row = group.querySelector(":scope > .sidebar-item-container");
    const label = row?.querySelector(
      ":scope > a.sidebar-item-text[data-bs-toggle='collapse']:not([href])",
    );
    if (!label) continue;

    const marker = label.querySelector('[class*="constell-group-"]');
    const colour = [...(marker?.classList ?? [])].find(
      name => name.startsWith("constell-group-"),
    );
    group.classList.add("constellate-sidebar-group");
    if (colour) {
      group.classList.add(colour);
      marker.classList.remove(colour);
    }

    const button = document.createElement("button");
    button.type = "button";
    for (const attribute of label.attributes) {
      if (attribute.name !== "role")
        button.setAttribute(attribute.name, attribute.value);
    }
    const target = button.getAttribute("data-bs-target");
    if (target?.startsWith("#"))
      button.setAttribute("aria-controls", target.slice(1));
    while (label.firstChild) button.append(label.firstChild);

    const arrow = document.createElement("i");
    arrow.className = "bi bi-chevron-right constellate-disclosure-icon";
    arrow.setAttribute("aria-hidden", "true");
    button.append(arrow);
    label.replaceWith(button);
    row.querySelector(":scope > .sidebar-item-toggle")?.remove();
  }
});
