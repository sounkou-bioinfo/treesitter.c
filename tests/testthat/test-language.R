test_that("language() returns valid language object", {
  skip_if_not_installed("treesitter")
  
  lang <- language()
  expect_s3_class(lang, "tree_sitter_language")
  expect_equal(treesitter::language_name(lang), "c")
})

test_that("can create parser with C language", {
  skip_if_not_installed("treesitter")
  
  lang <- language()
  parser <- treesitter::parser(lang)
  expect_s3_class(parser, "tree_sitter_parser")
})

test_that("can parse simple C struct", {
  skip_if_not_installed("treesitter")
  
  code <- "struct Point { int x; int y; };"
  
  lang <- language()
  parser <- treesitter::parser(lang)
  tree <- treesitter::parser_parse(parser, code)
  
  expect_s3_class(tree, "tree_sitter_tree")
  
  root <- treesitter::tree_root_node(tree)
  expect_s3_class(root, "tree_sitter_node")
})

test_that("parses array with symbolic dimension", {
  skip_if_not_installed("treesitter")
  
  code <- "struct Foo { int arr[MAX_SIZE]; };"
  
  lang <- language()
  parser <- treesitter::parser(lang)
  tree <- treesitter::parser_parse(parser, code)
  
  expect_s3_class(tree, "tree_sitter_tree")
})
