# language() returns valid language object
lang <- language()
expect_true(inherits(lang, "tree_sitter_language"))
expect_equal(treesitter::language_name(lang), "c")

# can create parser with C language
lang <- language()
parser <- treesitter::parser(lang)
expect_true(inherits(parser, "tree_sitter_parser"))

# can parse simple C struct
code <- "struct Point { int x; int y; };"

lang <- language()
parser <- treesitter::parser(lang)
tree <- treesitter::parser_parse(parser, code)

expect_true(inherits(tree, "tree_sitter_tree"))

root <- treesitter::tree_root_node(tree)
expect_true(inherits(root, "tree_sitter_node"))

# parses array with symbolic dimension
code <- "struct Foo { int arr[MAX_SIZE]; };"

lang <- language()
parser <- treesitter::parser(lang)
tree <- treesitter::parser_parse(parser, code)

expect_true(inherits(tree, "tree_sitter_tree"))
