
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

## Parsing R headers

Parse R headers installed on this machine, without preprocessing:

``` r
# Parse R headers installed on this machine (no preprocessing)
hdr_df <- parse_r_include_headers(
  dir = R.home("include"),
  preprocess = FALSE
)
```

Show the first few discovered functions matching “Rf”:

``` r
hdr_df[grepl("Rf", x = hdr_df$name), ] |> head(10)
#>                              name                                        file
#> 109  Rf_removeTaskCallbackByIndex      /usr/share/R/include/R_ext/Callbacks.h
#> 110   Rf_removeTaskCallbackByName      /usr/share/R/include/R_ext/Callbacks.h
#> 112            Rf_addTaskCallback      /usr/share/R/include/R_ext/Callbacks.h
#> 134                      Rf_error          /usr/share/R/include/R_ext/Error.h
#> 137                      Rf_error          /usr/share/R/include/R_ext/Error.h
#> 140                    Rf_warning          /usr/share/R/include/R_ext/Error.h
#> 251                     Rf_onintr /usr/share/R/include/R_ext/GraphicsDevice.h
#> 256                  Rf_ucstoutf8 /usr/share/R/include/R_ext/GraphicsDevice.h
#> 1031                  S_Rf_divset  /usr/share/R/include/R_ext/stats_package.h
#> 1037                  S_Rf_divset    /usr/share/R/include/R_ext/stats_stubs.h
#>      line        kind
#> 109    66 declaration
#> 110    67 declaration
#> 112    69 declaration
#> 134    58 declaration
#> 137    63     unknown
#> 140    69     unknown
#> 251   979 declaration
#> 256   990 declaration
#> 1031   56 declaration
#> 1037   41  definition
```

If you have a C compiler available and want to preprocess macros
(recommended for headers that use macros), enable `preprocess = TRUE`.
Prefer to use the helper `r_cc()` to detect the compiler automatically.

``` r
# Check for a compiler and use include_dirs so the preprocessor can find nested headers
cc <- treesitter.c::r_cc()
hdr_df_pp <- parse_r_include_headers(
    dir = R.home("include"),
    preprocess = TRUE,
    include_dirs = R.home("include")
  )
hdr_df_pp[grepl("Rf", x = hdr_df_pp$name), ] |> head(10)
#>                  name                                   file line        kind
#> 1597         Rf_error /usr/share/R/include/R_ext/Callbacks.h 2522 declaration
#> 1600       Rf_warning /usr/share/R/include/R_ext/Callbacks.h 2528 declaration
#> 1617       Rf_revsort /usr/share/R/include/R_ext/Callbacks.h 2567 declaration
#> 1618        Rf_iPsort /usr/share/R/include/R_ext/Callbacks.h 2568 declaration
#> 1619        Rf_rPsort /usr/share/R/include/R_ext/Callbacks.h 2569 declaration
#> 1620        Rf_cPsort /usr/share/R/include/R_ext/Callbacks.h 2570 declaration
#> 1626   Rf_StringFalse /usr/share/R/include/R_ext/Callbacks.h 2586 declaration
#> 1627    Rf_StringTrue /usr/share/R/include/R_ext/Callbacks.h 2587 declaration
#> 1628 Rf_isBlankString /usr/share/R/include/R_ext/Callbacks.h 2588 declaration
#> 1649        Rf_isNull /usr/share/R/include/R_ext/Callbacks.h 2698 declaration
```

## API Examples

The following concise examples demonstrate extracting specific
information (functions, parameters, structs, macros) using the API.

Simple parse and extract functions: parse a small header string and
extract functions with parameter types.

``` r
txt <- "int foo(int a, const char* s);
static inline int bar(void) { return 1; }"
# extract params and return type
root <- parse_header_text(txt)
get_function_nodes(root, extract_params = TRUE, extract_return = TRUE)
#>   capture_name text start_line start_col       params return_type
#> 1    decl_name  foo          1         5 int, con....         int
#> 2     def_name  bar          2        19         void         int
get_function_nodes(root, extract_params = TRUE)
#>   capture_name text start_line start_col       params return_type
#> 1    decl_name  foo          1         5 int, con....        <NA>
#> 2     def_name  bar          2        19         void        <NA>
```

Extract function parameter and return types while parsing:

``` r
txt <- "int foo(int a, const char* s);"
root <- parse_header_text(txt)
get_function_nodes(root, extract_params = TRUE, extract_return = TRUE)
#>   capture_name text start_line start_col       params return_type
#> 1    decl_name  foo          1         5 int, con....         int
```

Get structs and members:

``` r
txt <- "struct T { unsigned int x:1; int y; };"
root <- parse_header_text(txt)
get_struct_nodes(root)
#>   capture_name text start_line
#> 1  struct_name    T          1
get_struct_members(root)
#>   struct_name member_name member_type bitfield nested_members
#> 1           T           x        <NA>        1           <NA>
#> 2           T           y         int     <NA>           <NA>
```

Collect a directory with all kinds using `parse_headers_collect`

``` r
res <- parse_headers_collect(dir = R.home("include"), preprocess = FALSE, extract_params = TRUE)
names(res)
#> [1] "functions"      "structs"        "struct_members" "enums"         
#> [5] "unions"         "globals"        "defines"
head(res$functions)
#>                                  file capture_name start_line start_col
#> 1 /usr/share/R/include/R_ext/Altrep.h    decl_name         47         1
#> 2 /usr/share/R/include/R_ext/Altrep.h    decl_name         50         1
#> 3 /usr/share/R/include/R_ext/Altrep.h    decl_name         52         1
#> 4 /usr/share/R/include/R_ext/Altrep.h    decl_name         54         1
#> 5 /usr/share/R/include/R_ext/Altrep.h    decl_name         56         1
#> 6 /usr/share/R/include/R_ext/Altrep.h    decl_name         58         1
#>         params return_type                    name
#> 1 R_altrep....        <NA>            R_new_altrep
#> 2 const ch....        <NA>  R_make_altstring_class
#> 3 const ch....        <NA> R_make_altinteger_class
#> 4 const ch....        <NA>    R_make_altreal_class
#> 5 const ch....        <NA> R_make_altlogical_class
#> 6 const ch....        <NA>     R_make_altraw_class
# Optional: inspect macros from a single header
path <- file.path(R.home("include"), "Rembedded.h")
defs <- get_defines_from_file(path, use_cpp = TRUE, ccflags = paste("-I", dirname(path)))
  head(defs)
#> [1] "__DBL_MIN_EXP__"         "__UINT_LEAST16_MAX__"   
#> [3] "_STDBOOL_H"              "__FLT16_HAS_QUIET_NAN__"
#> [5] "__ATOMIC_ACQUIRE"        "__FLT128_MAX_10_EXP__"
```

## Details On the Used Grammar

treesiter ABI Version 14, compatible with treesitter package version
0.3.0. The C grammar source used for bootstrapping was downloaded from
<https://github.com/tree-sitter/tree-sitter-c>. The pre-generated
`parser.c` from upstream is ~3.7 MB and contains pragma directives that
trigger CRAN check warnings.

During bootstrap (`bootstrap.R`), all `#pragma` directives are
automatically removed from `parser.c` to ensure CRAN compliance. This
includes pragmas for diagnostic control and optimization settings that
are not portable across compilers.

## License

GPL-3
