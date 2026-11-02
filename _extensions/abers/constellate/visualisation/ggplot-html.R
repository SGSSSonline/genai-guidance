# Source with chdir = TRUE.
library(ggplot2)
source("ggplot.R")

knit_print.ggplot <- local({
  tokens_file <- "tokens.yml"
  themes <- lapply(c("light", "dark"), function(mode) {
    theme_constellate(mode, tokens_file)
  })
  theme_set(themes[[1]])

  function(x, options, ...) {
    if (!identical(unlist(options$renderings), c("light", "dark"))) {
      return(knitr::normal_print(x))
    }
    previous_theme <- theme_get()
    on.exit(theme_set(previous_theme), add = TRUE)
    for (plot_theme in themes) {
      theme_set(plot_theme)
      print(x)
    }
    invisible(NULL)
  }
})
