return {
  ["course-heading"] = function(args, kwargs, meta, raw_args, context)
    assert(context == "block", "course-heading: place the shortcode in a block by itself")
    local blocks = pandoc.Blocks({})
    local function content(key)
      local value = meta["course." .. key]
      if value == nil then return nil end
      value = quarto.utils.as_inlines(value:clone())
      for _, inline in ipairs(value) do
        if inline.t == "Str" then
          if inline.text:match("%S") then return value end
        elseif inline.t ~= "Space" and inline.t ~= "SoftBreak" and inline.t ~= "LineBreak" then
          return value
        end
      end
      return nil
    end
    local title = content("title")
    if title then blocks:insert(pandoc.Header(1, title)) end
    for _, field in ipairs({{ "subtitle", "subtitle" }, { "code", "course-code" }}) do
      local value = content(field[1])
      if value then blocks:insert(pandoc.Para({pandoc.Span(value, pandoc.Attr("", {field[2]}))})) end
    end
    if #blocks == 0 then return pandoc.Blocks({}) end
    return pandoc.Blocks({pandoc.Div(blocks, pandoc.Attr("", {"course-heading"}))})
  end,
}
