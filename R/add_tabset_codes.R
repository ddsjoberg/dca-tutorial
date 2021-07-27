#' Inserts Tabset Syntax by Language
#'
#' @param chunk_label chunk label stub
#'
#' @export
add_tabset_codes <- function(chunk_label) {
  res <-
    knitr::knit_child(
      text = unlist(knitr::knit_expand('templates/tabset-template.Rmd')),
      quiet = TRUE,
      envir = rlang::caller_env()
    )
  cat(res, sep = '\n')
}
