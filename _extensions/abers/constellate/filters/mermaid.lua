local figure = require("./diagram-figure")
return {
  CodeBlock = function(el)
    if not el.classes:includes("constell-mermaid") then
      return
    end
    el.classes = el.classes:filter(function(class)
      return class ~= "constell-mermaid"
    end)
    quarto.doc.add_html_dependency({
      name = "constellate-mermaid",
      version = tostring(quarto.version),
      scripts = {
        {
          path = pandoc.path.join({ os.getenv("QUARTO_SHARE_PATH"), "formats", "html", "mermaid", "mermaid.min.js" }),
          afterBody = true,
        },
        { path = "../scripts/mermaid.js", afterBody = true },
      },
    })
    local attributes = { ["data-source"] = el.text }
    if el.attributes["fig-alt"] ~= nil then
      attributes["data-alt"] = el.attributes["fig-alt"]
    end
    local content = pandoc.Div({},
      pandoc.Attr("", { "constellate-mermaid" }, attributes))
    return figure.wrap(el, content)
  end,
}
