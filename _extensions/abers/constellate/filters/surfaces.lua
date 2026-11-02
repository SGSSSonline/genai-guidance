local definitions, default_icons
local colours = {}
for name in ('rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender crust mantle base surface0 surface1 surface2'):gmatch('%S+') do
  colours[name] = true
end
local function fail(message) assert(false, 'surface: '..message) end
local function is_map(value)
  return pandoc.utils.type(value) == 'table'
end
local function icon_policy(value, label)
  if value == true or value == 'true' then return true end
  if value == false or value == 'false' then return false end
  fail(label..' must be true or false')
end
local function blend_percentage(value)
  if value == nil then return 100 end
  local kind = pandoc.utils.type(value)
  if type(value) ~= 'number' and type(value) ~= 'string' and kind ~= 'Inlines' then
    fail('blend must be a number from 0 to 100')
  end
  local number = tonumber(pandoc.utils.stringify(value))
  if not number or number < 0 or number > 100 then
    fail('blend must be a number from 0 to 100')
  end
  return number
end
local function rich(value, label)
  if value == nil then return pandoc.Inlines({}) end
  if type(value) == 'string' then return quarto.utils.string_to_inlines(value) end
  local kind = pandoc.utils.type(value)
  if kind ~= 'Inlines' and kind ~= 'Blocks' then fail(label..' must be inline Markdown') end
  return quarto.utils.as_inlines(value)
end
local function visible(inlines)
  for _, inline in ipairs(inlines) do
    if inline.t == 'Str' then
      if inline.text:match('%S') then return true end
    elseif inline.t ~= 'Space' and inline.t ~= 'SoftBreak' and inline.t ~= 'LineBreak' then return true end
  end
  return false
end
local function resolve(element)
  local names = {}
  for _, class in ipairs(element.classes) do
    local name = class:match('^surface%-(.*)$')
    if name ~= nil then names[#names + 1] = name end
  end
  if #names == 0 and not element.classes:includes('surface') then return end
  if #names > 1 then fail('use one configured surface class; found '..table.concat(names, ', ')) end
  local name = names[1]
  local definition = name and definitions[name]
  if name and definition == nil then fail('unknown configured class .surface-'..name) end
  if name and not is_map(definition) then
    fail('surfaces.'..name..' must contain colour and optional title/icon fields')
  end
  local colour = element.attributes.colour
  if name then
    if definition.colour == nil then fail('surfaces.'..name..' needs a named colour') end
    colour = pandoc.utils.stringify(definition.colour)
  end
  if not colour or colour == '' then fail((name and '.surface-'..name or '.surface')..' needs colour=...') end
  if not colours[colour] then fail('unknown colour '..colour..'; use a canonical named accent or neutral surface colour') end
  if definition and element.attributes.colour ~= nil and element.attributes.colour ~= colour then
    fail('.surface-'..name..' fixes colour '..colour..'; use plain .surface colour=... for another colour')
  end
  local local_blend = blend_percentage(element.attributes.blend)
  local blend = definition and blend_percentage(definition.blend) or local_blend
  if definition and element.attributes.blend ~= nil and local_blend ~= blend then
    fail('.surface-'..name..' fixes blend '..blend..'; use plain .surface colour=... for another blend')
  end
  local icons = default_icons
  if element.attributes.icon ~= nil then icons = icon_policy(element.attributes.icon, 'icon') end
  local title
  if element.attributes.title ~= nil then
    if element.t == 'Header' then fail('use the native slide heading instead of Header title=...') end
    title = rich(element.attributes.title, 'title')
  elseif element.t == 'Header' and visible(element.content) then
    title = element.content
  else
    title = rich(definition and definition.title, 'surface title')
  end
  local icon = icons and rich(definition and definition.icon, 'surface icon') or pandoc.Inlines({})
  return {name=name, title=title, icon=icon, colour=colour, blend=blend}
end
local function apply_attributes(element, value)
  element.attributes.colour = nil
  element.attributes.icon = nil
  element.attributes.title = nil
  element.attributes.blend = nil
  element.attributes['data-surface-colour'] = value.colour
end
local function lead(value)
  local parts = pandoc.Inlines({})
  if visible(value.icon) then parts:insert(pandoc.Span(value.icon, pandoc.Attr('', {'constellate-surface-icon'}, {['aria-hidden']='true'}))) end
  if visible(value.title) then parts:insert(pandoc.Span(value.title, pandoc.Attr('', {'constellate-surface-title'}))) end
  return parts
end
local filter = {Div=function(div)
  local value = resolve(div)
  if not value then return end
  apply_attributes(div, value)
  if not div.classes:includes('surface') then div.classes:insert('surface') end
  if value.blend ~= 100 then
    local style = div.attributes.style
    div.attributes.style = (style and style ~= '' and style..';' or '')
      ..'--surface-blend:'..value.blend..'%;'
  end
  local parts = lead(value)
  if #parts > 0 then div.content:insert(1, pandoc.Div({pandoc.Para(parts)}, pandoc.Attr('', {'constellate-surface-lead'}))) end
  return div
end, Header=function(header)
  local value = resolve(header)
  if not value then return end
  if not quarto.doc.is_format('revealjs') then fail('whole-slide surface classes require a native Reveal slide heading') end
  if not value.name then fail('plain .surface colour=... belongs on a contained Div; use a configured class for a whole slide') end
  local slide_level = PANDOC_WRITER_OPTIONS.slide_level
  if not slide_level or slide_level == 0 or header.level > slide_level then
    fail('configured surface class must be on a native slide heading; current slide-level is '..tostring(slide_level))
  end
  apply_attributes(header, value)
  header.content = lead(value)
  header.attributes['data-background-color'] = nil
  header.attributes['background-color'] = 'var(--surface-'..value.colour..')'
  if value.blend ~= 100 then
    local mix = 'color-mix(in srgb, var(--surface-'..value.colour..') '..value.blend..'%, var(--surface-canvas, var(--surface-base)))'
    header.attributes['background-color'] = mix
  end
  return header
end}

return {Pandoc=function(doc)
  local meta = doc.meta
  if meta.surfaces ~= nil and not is_map(meta.surfaces) then fail('surfaces must be a map of named definitions') end
  definitions = meta.surfaces or {}
  default_icons = meta['surface-icon'] == nil or icon_policy(meta['surface-icon'], 'surface-icon')
  return doc:walk(filter)
end}
