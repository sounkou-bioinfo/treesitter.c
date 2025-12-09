#' Get the path to the installed fake_libc headers
#'
#' Returns the absolute path to the inst/fake_libc directory in the installed package.
#'
#' @return Character scalar with the path to fake_libc headers
#' @export
fake_libc_path <- function() {
    normalizePath(system.file("fake_libc", package = "treesitter.c"))
}
