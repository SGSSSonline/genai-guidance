local graph_number = 0
return {
  CodeBlock = function(el)
    if not el.classes:includes('constell-dot') then return end
    el.classes = el.classes:filter(function(c) return c ~= 'constell-dot' end)
    graph_number = graph_number + 1
    local mode = pandoc.utils.stringify(quarto.metadata.get('brand-mode') or 'light')
    local family = quarto.brand.get_typography(mode, 'base').family
    local svg = pandoc.pipe('dot', {
      '-Tsvg', '-Gid=constellate-dot-' .. graph_number,
      '-Gfontname=' .. family, '-Nfontname=' .. family,
      '-Efontname=' .. family,
    }, el.text)
    local attributes = {}
    local alt = el.attributes['fig-alt']
    if alt then
      attributes = alt == '' and {['aria-hidden']='true'} or {role='img', ['aria-label']=alt}
    end
    local content = pandoc.Div({pandoc.RawBlock('html', svg)},
      pandoc.Attr('', {'constellate-dot'}, attributes))
    return require("./diagram-figure").wrap(el, content)
  end,
}
