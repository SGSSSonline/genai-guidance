local function fail(message)
  assert(false, "split: " .. message)
end

local function split(div)
  if not div.classes:includes("split") then return nil end
  for _, option in ipairs({"larger", "narrow-first"}) do
    local value = div.attributes[option]
    if value and value ~= "left" and value ~= "right" then
      fail(option .. " must be left or right")
    end
  end
  local sides = {}
  for _, child in ipairs(div.content) do
    if child.t ~= "Div" then fail("use one split-left and one split-right direct Div") end
    local left = child.classes:includes("split-left")
    local right = child.classes:includes("split-right")
    if left == right then fail("each direct Div needs exactly one side: split-left or split-right") end
    local side = left and "left" or "right"
    if sides[side] then fail("duplicate split-" .. side .. " Div") end
    sides[side] = child
  end
  if not sides.left or not sides.right then fail("use one split-left and one split-right direct Div") end
  local first = div.attributes["narrow-first"] or "left"
  div.attributes["narrow-first"] = nil
  div.content = pandoc.Blocks({sides[first], sides[first == "left" and "right" or "left"]})
  return div
end

local function lead(attributes)
  local parts = pandoc.Inlines({})
  for _, field in ipairs({"icon", "title"}) do
    local value = attributes[field]
    if value and value:match("%S") then
      local inlines = quarto.utils.string_to_inlines(value)
      if #inlines > 0 then
        local attr = pandoc.Attr("", {"content-column-" .. field})
        if field == "icon" then attr.attributes["aria-hidden"] = "true" end
        parts:insert(pandoc.Span(inlines, attr))
      end
    end
    attributes[field] = nil
  end
  if #parts > 0 then
    return pandoc.Para({pandoc.Span(parts, pandoc.Attr("", {"content-column-lead"}))})
  end
end

local function columns(div)
  if not div.classes:includes("content-columns") then return nil end
  if #div.content < 2 or #div.content > 3 then
    assert(false, "content-columns: use two or three direct Divs")
  end
  for _, child in ipairs(div.content) do
    if child.t ~= "Div" then
      assert(false, "content-columns: every direct child must be a Div")
    end
    local label = lead(child.attributes)
    if label then child.content:insert(1, label) end
  end
  return div
end

local function transform(div)
  local result = split(div)
  return columns(result or div) or result
end
local function button(link)
  if not link.classes:includes("button") then return nil end
  if not link.classes:includes("btn") then link.classes:insert("btn") end
  return link
end
return {Pandoc = function(doc)
    for _, block in ipairs(doc.blocks) do
      if block.t == "Div" and block.classes:includes("wide") and not block.classes:includes("column-body-outset") then
        block.classes:insert("column-body-outset")
      end
    end
    doc = doc:walk({Div = transform})
    return doc:walk({Link = button})
end}
