# treesitter.c

C grammar for the R treesitter package.

## Installation

``` r
# Install treesitter.c from GitHub
remotes::install_git("https://github.com/sounkou-bioinfo/treesitter.c")
```

## Usage

``` r
library(treesitter)
#> 
#> Attaching package: 'treesitter'
#> The following object is masked from 'package:base':
#> 
#>     range
library(treesitter.c)

c_language <- language()
parser <- parser(c_language)

code <- "
struct Point {
  int x[MAX_SIZE];
  int y;
};
"

tree <- parser_parse(parser, code)
tree
#> <tree_sitter_tree>
#> 
#> ── Text ─────────────────────────────────────────────────────────────────────────────────────────────────────────
#> struct Point {
#>   int x[MAX_SIZE];
#>   int y;
#> };
#> 
#> 
#> ── S-Expression ─────────────────────────────────────────────────────────────────────────────────────────────────
#> (translation_unit [(1, 0), (5, 0)]
#>   (struct_specifier [(1, 0), (4, 1)]
#>     "struct" [(1, 0), (1, 6)]
#>     name: (type_identifier [(1, 7), (1, 12)])
#>     body: (field_declaration_list [(1, 13), (4, 1)]
#>       "{" [(1, 13), (1, 14)]
#>       (field_declaration [(2, 2), (2, 18)]
#>         type: (primitive_type [(2, 2), (2, 5)])
#>         declarator: (array_declarator [(2, 6), (2, 17)]
#>           declarator: (field_identifier [(2, 6), (2, 7)])
#>           "[" [(2, 7), (2, 8)]
#>           size: (identifier [(2, 8), (2, 16)])
#>           "]" [(2, 16), (2, 17)]
#>         )
#>         ";" [(2, 17), (2, 18)]
#>       )
#>       (field_declaration [(3, 2), (3, 8)]
#>         type: (primitive_type [(3, 2), (3, 5)])
#>         declarator: (field_identifier [(3, 6), (3, 7)])
#>         ";" [(3, 7), (3, 8)]
#>       )
#>       "}" [(4, 0), (4, 1)]
#>     )
#>   )
#>   ";" [(4, 1), (4, 2)]
#> <truncated>
```

## Details

**ABI Version 14**, compatible with treesitter package version 0.3.0.
The C grammar source used for bootstrapping was downloaded from
<https://github.com/tree-sitter/tree-sitter-c>. The pre-generated
`parser.c` from upstream is ~3.7 MB and contains pragma directives that
trigger CRAN check warnings.

During bootstrap (`bootstrap.R`), all `#pragma` directives are
automatically removed from `parser.c` to ensure CRAN compliance. This
includes pragmas for diagnostic control and optimization settings that
are not portable across compilers.

## License

GPL-3
