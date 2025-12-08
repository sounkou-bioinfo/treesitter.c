
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
# Parse R headers installed on this machine
hdr_df <- parse_r_include_headers(dir = R.home("include"), preprocess = FALSE)
# Show the first few functions discovered
hdr_df[
  grepl("Rf", x = hdr_df$name),] |>
      head(10)
#>                             name                                        file
#> 25  Rf_removeTaskCallbackByIndex      /usr/share/R/include/R_ext/Callbacks.h
#> 26   Rf_removeTaskCallbackByName      /usr/share/R/include/R_ext/Callbacks.h
#> 57                     Rf_onintr /usr/share/R/include/R_ext/GraphicsDevice.h
#> 59                  Rf_ucstoutf8 /usr/share/R/include/R_ext/GraphicsDevice.h
#> 236                  S_Rf_divset  /usr/share/R/include/R_ext/stats_package.h
#> 242                  S_Rf_divset    /usr/share/R/include/R_ext/stats_stubs.h
#> 273             Rf_initEmbeddedR            /usr/share/R/include/Rembedded.h
#> 274              Rf_endEmbeddedR            /usr/share/R/include/Rembedded.h
#> 275              Rf_initialize_R            /usr/share/R/include/Rembedded.h
#> 282            Rf_KillAllDevices            /usr/share/R/include/Rembedded.h
#>     line        kind
#> 25    66 declaration
#> 26    67 declaration
#> 57   979 declaration
#> 59   990 declaration
#> 236   56 declaration
#> 242   41  definition
#> 273   32 declaration
#> 274   33 declaration
#> 275   42 declaration
#> 282   50 declaration

# If you have a C compiler available and want to preprocess macros
# (recommended for headers that use macros for types), enable preprocess = TRUE.
# Prefer to use the helper `r_cc()` defined in the package which consults R's
# configuration and environment. This ensures consistent behavior across
# platforms and environments.
cc <- treesitter.c::r_cc()
# When preprocessing system headers, pass the include path via `include_dirs` so
# the preprocessor can find nested headers and macros correctly.
hdr_df_pp <- parse_r_include_headers(dir = R.home("include"), preprocess = TRUE, include_dirs = R.home("include"))
hdr_df_pp[
  grepl("Rf", x = hdr_df_pp$name),] |>
      head(10)
#>                  name                                   file line        kind
#> 1483         Rf_error /usr/share/R/include/R_ext/Callbacks.h 2522 declaration
#> 1486       Rf_warning /usr/share/R/include/R_ext/Callbacks.h 2528 declaration
#> 1495       Rf_revsort /usr/share/R/include/R_ext/Callbacks.h 2567 declaration
#> 1496        Rf_iPsort /usr/share/R/include/R_ext/Callbacks.h 2568 declaration
#> 1497        Rf_rPsort /usr/share/R/include/R_ext/Callbacks.h 2569 declaration
#> 1498        Rf_cPsort /usr/share/R/include/R_ext/Callbacks.h 2570 declaration
#> 1503   Rf_StringFalse /usr/share/R/include/R_ext/Callbacks.h 2586 declaration
#> 1504    Rf_StringTrue /usr/share/R/include/R_ext/Callbacks.h 2587 declaration
#> 1505 Rf_isBlankString /usr/share/R/include/R_ext/Callbacks.h 2588 declaration
#> 1557        Rf_asChar /usr/share/R/include/R_ext/Callbacks.h 2922 declaration
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
