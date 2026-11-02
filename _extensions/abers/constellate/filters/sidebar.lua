local function boolean_option(options, name)
  local value = options[name]
  assert(value == nil or type(value) == "boolean",
    "constellate.sidebar." .. name .. " must be true or false")
  return value == true
end

function Meta(meta)
  if not quarto.doc.is_format("html") then return meta end
  local options = meta.constellate and meta.constellate.sidebar
  if not options then return meta end

  local grouped = boolean_option(options, "grouped")
  local light_alternative = boolean_option(options, "light-alternative")
  if not grouped and not light_alternative then return meta end

  local markers = {}
  local dependency = {
    name = "constellate-sidebar",
    version = "0.1.0",
    meta = markers
  }
  if grouped then
    markers["constellate-sidebar-groups"] = "true"
    dependency.scripts = { "../scripts/sidebar.js" }
  end
  if light_alternative then
    markers["constellate-sidebar-light-alternative"] = "true"
  end

  quarto.doc.add_html_dependency(dependency)
  return meta
end
