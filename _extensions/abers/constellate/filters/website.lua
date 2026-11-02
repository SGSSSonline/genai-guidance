function Meta(meta)
  local settings = meta.constellate or {}
  local markers = {}
  local dependency = { name = "constellate-website", version = "1.0.0", meta = markers }
  if settings.sidebar and settings.sidebar.grouped == true then
    markers["constellate-sidebar-groups"] = "true"
    if settings.sidebar["hero-colour"] == true then
      markers["constellate-sidebar-hero-colour"] = "true"
    end
    if settings.sidebar["active-group-colour"] == true then
      markers["constellate-sidebar-active-group-colour"] = "true"
    end
    if settings.sidebar["collapsed-colour"] == false then
      markers["constellate-sidebar-collapsed-colour"] = "false"
    end
    dependency.scripts = { "../scripts/sidebar.js" }
  end
  if settings.navbar and settings.navbar.border == true then
    markers["constellate-navbar-border"] = "true"
  end
  local layout = settings.layout
  for _, name in ipairs({ "article-card", "light-surround" }) do
    if layout and layout[name] == true then
      markers["constellate-layout-" .. name] = "true"
    end
  end
  if layout and layout["hero-overlap"] then
    markers["constellate-layout-hero-overlap"] = pandoc.utils.stringify(layout["hero-overlap"])
  end
  if layout and layout["toc-background"] then
    markers["constellate-layout-toc-background"] = pandoc.utils.stringify(layout["toc-background"])
  end
  if next(markers) then
    quarto.doc.add_html_dependency(dependency)
  end
end
