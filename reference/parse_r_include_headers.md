# Parse C header files for function declarations using tree-sitter

This utility uses the C language provided by this package and the
treesitter parser to find function declarations and definitions in C
header files. The default `dir` is `R.home("include")`, which is
typically where R's headers live.

## Usage

``` r
parse_r_include_headers(
  dir = R.home("include"),
  recursive = TRUE,
  pattern = c("\\.h$", "\\.H$"),
  preprocess = FALSE,
  cc = r_cc(),
  ccflags = NULL,
  include_dirs = NULL,
  ...
)
```

## Arguments

- dir:

  Directory to search for header files. Defaults to `R.home("include")`.

- recursive:

  Whether to search recursively for headers. Default `TRUE`.

- pattern:

  File name pattern to match header files. Default is `\.h$` and `\.H$`.

- preprocess:

  Run the C preprocessor (using R's configured CC) on header files
  before parsing. Defaults to `FALSE`.

- cc:

  The C compiler to use for preprocessing. If `NULL` the function
  queries `R CMD config CC` and falls back to `Sys.getenv("CC")` and the
  `cc` on PATH.

- ccflags:

  Extra flags to pass to the compiler when preprocessing. If `NULL`
  flags are taken from `R CMD config CFLAGS` and
  `R CMD config CPPFLAGS`.

- include_dirs:

  Additional directories to add to the include path for preprocessing. A
  character vector of directories.

- ...:

  Arguments passed on to
  [`parse_headers_collect`](https://sounkou-bioinfo.github.io/treesitter.c/reference/parse_headers_collect.md)

  `extract_params`

  :   Logical; whether to extract parameter types for functions. Default
      `FALSE`.

  `extract_return`

  :   Logical; whether to extract return types for functions. Default
      `FALSE`.

## Value

A data frame with columns `name`, `file`, `line`, and `kind` (either
'declaration' or 'definition').

## Examples

``` r
if (requireNamespace("treesitter", quietly = TRUE)) {
  # Parse a small header file from a temp dir
  tmp <- tempdir()
  path <- file.path(tmp, "example.h")
  writeLines(c(
    "int foo(int a);",
    "static inline int bar(void) { return 1; }"
  ), path)
  parse_r_include_headers(dir = tmp)
}
#>   name                      file line        kind
#> 1  foo /tmp/RtmpghDBZ6/example.h    1 declaration
#> 2  bar /tmp/RtmpghDBZ6/example.h    2  definition
```
