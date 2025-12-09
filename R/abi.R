#' tree-sitter ABI version
#'
#' @returns A single integer.
#' @noRd
abi <- function() {
  .Call(treesitter_language_abi, PACKAGE = "treesitter.c")
}
