constellate_visuals <- function(mode = c("light", "dark"), tokens_file) {
  mode <- match.arg(mode)
  tokens <- yaml::read_yaml(tokens_file)
  list(colours = tokens$modes[[mode]], fonts = tokens$fonts)
}

theme_constellate <- function(mode = c("light", "dark"), tokens_file,
                              base_size = 12) {
  visuals <- constellate_visuals(mode, tokens_file)
  palette <- visuals$colours
  ggplot2::theme_minimal(
    base_size = base_size,
    base_family = visuals$fonts$base,
    ink = palette$text,
    paper = palette$background,
    accent = palette$series[[1]]
  ) + ggplot2::theme(
    plot.title = ggplot2::element_text(family = visuals$fonts$headings, face = "bold"),
    panel.grid = ggplot2::element_line(colour = palette$grid),
    axis.text = ggplot2::element_text(colour = palette$text),
    strip.text = ggplot2::element_text(colour = palette$text),
    palette.colour.discrete = palette$series,
    palette.fill.discrete = palette$series,
    palette.colour.continuous = palette$sequential,
    palette.fill.continuous = palette$sequential
  )

}

scale_colour_constellate <- function(mode = c("light", "dark"), tokens_file, na.value = NULL, ...) {
  palette <- constellate_visuals(mode, tokens_file)$colours
  ggplot2::scale_colour_manual(values = palette$series,
    na.value = if (is.null(na.value)) palette$muted else na.value, ...)
}
scale_fill_constellate <- function(mode = c("light", "dark"), tokens_file, na.value = NULL, ...) {
  palette <- constellate_visuals(mode, tokens_file)$colours
  ggplot2::scale_fill_manual(values = palette$series,
    na.value = if (is.null(na.value)) palette$muted else na.value, ...)
}
scale_colour_constellate_continuous <- function(mode = c("light", "dark"), tokens_file, na.value = NULL, ...) {
  palette <- constellate_visuals(mode, tokens_file)$colours
  ggplot2::scale_colour_gradient(low = palette$sequential[[1]], high = palette$sequential[[2]],
                                na.value = if (is.null(na.value)) palette$muted else na.value, ...)
}
scale_fill_constellate_continuous <- function(mode = c("light", "dark"), tokens_file, na.value = NULL, ...) {
  palette <- constellate_visuals(mode, tokens_file)$colours
  ggplot2::scale_fill_gradient(low = palette$sequential[[1]], high = palette$sequential[[2]],
                              na.value = if (is.null(na.value)) palette$muted else na.value, ...)
}
