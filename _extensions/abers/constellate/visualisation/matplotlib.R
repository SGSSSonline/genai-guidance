local({
  styles <- normalizePath(paste0("constellate-", c("light", "dark"), ".mplstyle"))
  knitr::knit_engines$set(python = function(options) {
    if (!identical(unlist(options$renderings), c("light", "dark")) || !isTRUE(options$eval)) {
      return(reticulate::eng_python(options))
    }
    style <- reticulate::import("matplotlib.style")
    output <- vector("list", 2)
    for (i in seq_along(styles)) {
      variant <- options
      if (i == 2) variant$echo <- FALSE
      output[[i]] <- with(style$context(styles[i]), reticulate::eng_python(variant))
    }
    unlist(output, use.names = FALSE)
  })
})
