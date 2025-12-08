
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
#> ── Text ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#> struct Point {
#>   int x[MAX_SIZE];
#>   int y;
#> };
#> 
#> 
#> ── S-Expression ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
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

## Parsing R headers (example)

``` r
if (requireNamespace("treesitter", quietly = TRUE)) {
  # Parse R headers installed on this machine
  hdr_df <- parse_r_include_headers(dir = R.home("include"), preprocess = FALSE)
  # Show the first few functions discovered
  hdr_df[1:10, ]

  # If you have a C compiler available and want to preprocess macros
  # (recommended for headers that use macros for types), enable preprocess = TRUE.
  # Prefer to use the helper `r_cc()` defined in the package which consults R's
  # configuration and environment. This ensures consistent behavior across
  # platforms and environments.
  cc <- treesitter.c::r_cc()
  if (nzchar(cc)) {
    hdr_df_pp <- parse_r_include_headers(dir = R.home("include"), preprocess = TRUE)
    hdr_df_pp[1:10, ]
  }
}
#>                 name                                   file line        kind
#> 1         __bswap_16 /usr/share/R/include/R_ext/eventloop.h  327  definition
#> 2         __bswap_32 /usr/share/R/include/R_ext/eventloop.h  342  definition
#> 3         __bswap_64 /usr/share/R/include/R_ext/eventloop.h  352  definition
#> 4  __uint16_identity /usr/share/R/include/R_ext/eventloop.h  364  definition
#> 5  __uint32_identity /usr/share/R/include/R_ext/eventloop.h  370  definition
#> 6  __uint64_identity /usr/share/R/include/R_ext/eventloop.h  376  definition
#> 7             select /usr/share/R/include/R_ext/eventloop.h  480 declaration
#> 8            pselect /usr/share/R/include/R_ext/eventloop.h  485 declaration
#> 9        __fdelt_chk /usr/share/R/include/R_ext/eventloop.h  495 declaration
#> 10      __fdelt_warn /usr/share/R/include/R_ext/eventloop.h  496 declaration
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
