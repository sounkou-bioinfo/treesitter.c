#' tree-sitter ABI version
#'
#' @returns A single integer.
#' @noRd
abi <- function() {
  # ABI version 14 (compatible with treesitter 0.3.0)
  .Call(treesitter_language_abi, PACKAGE = "treesitter.c")
}
