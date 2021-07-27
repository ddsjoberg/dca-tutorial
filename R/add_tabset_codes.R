#' Title
#'
#' @param chunk_label chunk label stub
#'
#' @return
#' @export
add_tabset_codes <- function(chunk_label) {
  res <-
    knitr::knit_child(
      text = unlist(knitr::knit_expand('templates/tabset-template.Rmd')),
      quiet = TRUE
    )
  cat(res, sep = '\n')
}
