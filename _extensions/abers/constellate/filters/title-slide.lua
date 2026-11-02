function Meta(meta)
  local attrs = meta["title-slide-attributes"] or pandoc.MetaMap({})
  local classes = attrs.class and pandoc.utils.stringify(attrs.class) or ""
  attrs.class = pandoc.MetaString(classes == "" and "title-slide-custom" or classes .. " title-slide-custom")
  meta["title-slide-attributes"] = attrs
  return meta
end
