local function identity(file, alt, label, name, url)
  return pandoc.Div({
    pandoc.Para({
      pandoc.Image(
        { pandoc.Str(alt) },
        pandoc.path.make_relative(
          quarto.utils.resolve_path("../assets/" .. file),
          pandoc.path.directory(quarto.doc.input_file),
          true
        )
      ),
    }),
    pandoc.Para({
      pandoc.Str(label),
      pandoc.Space(),
      pandoc.Link({ pandoc.Str(name) }, url, "", pandoc.Attr("", { "identity-name" })),
    }),
  }, pandoc.Attr("", { "constell-identity" }))
end

local function colophon(stretch)
  local classes = { "colophon" }
  if stretch then table.insert(classes, "r-stretch") end
  local result = pandoc.Blocks({})
  if quarto.doc.is_format("revealjs") then
    result:insert(pandoc.HorizontalRule())
  end
  result:insert(pandoc.Div({
    identity("quarto-logo.svg", "Quarto logo", "Made with", "Quarto", "https://quarto.org/"),
    identity("cat-logo.png", "Catppuccin logo", "Colour scheme", "Catppuccin", "https://catppuccin.com/"),
  }, pandoc.Attr("", classes)))
  return result
end

local function licence()
  return quarto.utils.string_to_inlines([[Licensed under [{{< fa brands creative-commons >}} {{< fa brands creative-commons-by >}} {{< fa brands creative-commons-sa >}}]{aria-hidden="true"} [Creative Commons BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)]])
end

return {
  ["constell-made-with"] = function()
    return colophon(false)
  end,
  ["cc-by-sa"] = function()
    return licence()
  end,
  ["closing-slide"] = function(_args, _kwargs, _meta, _raw_args, context)
    local message
    if not quarto.doc.is_format("revealjs") then
      message = "use this shortcode in Reveal slides; use constell-made-with and cc-by-sa separately in HTML"
    elseif context ~= "block" then
      message = "place this shortcode on its own line"
    end
    if message then
      quarto.log.error("closing-slide: " .. message)
      return quarto.shortcode.error_output("closing-slide", message, context)
    end
    local result = colophon(true)
    result:insert(pandoc.Div({pandoc.Para(licence())}, pandoc.Attr("", {"absolute", "closing-credit"}, {
      bottom = "40", left = "0", right = "0"
    })))
    return result
  end,
}
