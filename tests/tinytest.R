library(treesitter.c)
if (requireNamespace("tinytest", quietly = TRUE)) {
  tinytest::test_package("treesitter.c")
}
