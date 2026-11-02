local M = {}
function M.wrap(el, content)
  if el.attributes["fig-cap"] or el.identifier:match("^fig%-") then
    return quarto.FloatRefTarget({
      type = "Figure",
      attr = el.attr,
      caption_long = pandoc.read(el.attributes["fig-cap"] or "", "markdown").blocks,
      content = { content },
    })
  end
  return pandoc.Div({ content }, el.attr)
end
return M
