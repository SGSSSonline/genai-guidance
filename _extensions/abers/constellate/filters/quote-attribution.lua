local function split_attribution(quote)
  local body = quote.content
  local last = body[#body]
  if not last then
    return body, nil
  end

  if #body > 1 and last.t == "BulletList" and #last.content == 1 then
    local item = last.content[1]
    if
      #item == 1
      and (item[1].t == "Plain" or item[1].t == "Para")
      and pandoc.utils.stringify(item[1].content):match("%S")
    then
      body:remove(#body)
      return body, item[1].content
    end
  end

  if last.t == "Para" then
    local content = last.content
    local last_break
    for index, inline in ipairs(content) do
      if inline.t == "SoftBreak" or inline.t == "LineBreak" then
        last_break = index
      end
    end
    if
      last_break
      and content[last_break + 1]
      and content[last_break + 1].t == "Str"
      and content[last_break + 1].text == "-"
      and content[last_break + 2]
      and content[last_break + 2].t == "Space"
      and content[last_break + 3]
    then
      local quoted = pandoc.Inlines({})
      local attribution = pandoc.Inlines({})
      for index = 1, last_break - 1 do
        quoted:insert(content[index])
      end
      for index = last_break + 3, #content do
        attribution:insert(content[index])
      end
      if pandoc.utils.stringify(quoted):match("%S") then
        body[#body] = pandoc.Para(quoted)
        return body, attribution
      end
    end
  end
  return body, nil
end

local function ornament(which)
  return pandoc.Span(
    {},
    pandoc.Attr("", { "quote-ornament", "quote-" .. which }, { ["aria-hidden"] = "true" })
  )
end

local function add_inline_marks(body)
  local first, last = body[1], body[#body]
  if not first then
    return
  end

  if last.t == "Para" or last.t == "Plain" then
    local content = last.content
    local tail = pandoc.Inlines({})
    while #content > 0 do
      local inline = content[#content]
      if inline.t == "Space" or inline.t == "SoftBreak" or inline.t == "LineBreak" then
        break
      end
      tail:insert(1, content:remove(#content))
    end
    tail:insert(ornament("close"))
    if pandoc.utils.stringify(tail):find("%s") then
      content:extend(tail)
    else
      content:insert(pandoc.Span(tail, pandoc.Attr("", { "quote-tail-joined" })))
    end
  end

  if first.t == "Para" or first.t == "Plain" then
    first.content:insert(1, ornament("open"))
  end
end

local function render_quote(quote)
  local body, attribution = split_attribution(quote)
  add_inline_marks(body)

  local caption = pandoc.Blocks({})
  if attribution then
    local inlines = pandoc.Inlines({
      pandoc.Span({ pandoc.Str("—") }, pandoc.Attr("", { "quote-attribution-mark" })),
      pandoc.Space(),
    })
    inlines:extend(attribution)
    caption:insert(pandoc.Para(inlines))
  end
  return pandoc.Figure(
    { pandoc.BlockQuote(body) },
    pandoc.Caption(caption),
    pandoc.Attr("", { "constellate-quote" })
  )
end

return { BlockQuote = render_quote }
