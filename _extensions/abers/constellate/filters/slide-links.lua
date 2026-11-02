return {
  Pandoc = function()
    if not quarto.project.directory then
      return
    end
    if quarto.metadata.get("slides-follow-theme") ~= true then
      return
    end
    local path = pandoc.path.join({ quarto.project.offset, "slide-variants.js" })
    quarto.doc.include_text(
      "after-body",
      '<script id="slide-variant-manifest" src="' .. path .. '"></script>'
    )
    quarto.doc.add_html_dependency({
      name = "slide-variants",
      version = "1.0.0",
      scripts = { { path = "../scripts/slide-links.js", afterBody = true } },
    })
  end,
}
