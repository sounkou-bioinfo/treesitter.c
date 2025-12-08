# Convert character content of a header file into a tree-sitter root

Convert character content of a header file into a tree-sitter root

## Usage

``` r
parse_header_text(text, lang = language())
```

## Arguments

- text:

  Character scalar with the header content to parse.

- lang:

  tree-sitter language object (default: C language from package)

## Value

The tree root node object

## Examples

``` r
if (requireNamespace("treesitter", quietly = TRUE)) {
    root <- parse_header_text("int foo(int);\n")
    root
}
#> <tree_sitter_node>
#> 
#> ── Text ────────────────────────────────────────────────────────────────────────
#> int foo(int);
#> 
#> 
#> ── S-Expression ────────────────────────────────────────────────────────────────
#> (translation_unit [(0, 0), (1, 0)]
#>   (declaration [(0, 0), (0, 13)]
#>     type: (primitive_type [(0, 0), (0, 3)])
#>     declarator: (function_declarator [(0, 4), (0, 12)]
#>       declarator: (identifier [(0, 4), (0, 7)])
#>       parameters: (parameter_list [(0, 7), (0, 12)]
#>         "(" [(0, 7), (0, 8)]
#>         (parameter_declaration [(0, 8), (0, 11)]
#>           type: (primitive_type [(0, 8), (0, 11)])
#>         )
#>         ")" [(0, 11), (0, 12)]
#>       )
#>     )
#>     ";" [(0, 12), (0, 13)]
#>   )
#> )
```
