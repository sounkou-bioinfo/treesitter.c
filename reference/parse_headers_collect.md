# Parse a directory of headers and return named list of data.frames with

functions, structs, struct members, enums, unions, globals, and macros.

## Usage

``` r
parse_headers_collect(
  dir = R.home("include"),
  recursive = TRUE,
  pattern = c("\\.h$", "\\.H$"),
  preprocess = FALSE,
  cc = r_cc(),
  ccflags = NULL,
  include_dirs = NULL,
  extract_params = FALSE,
  extract_return = FALSE,
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

- extract_params:

  Logical; whether to extract parameter types for functions. Default
  `FALSE`.

- extract_return:

  Logical; whether to extract return types for functions. Default
  `FALSE`.

- ...:

  Additional arguments passed to preprocess_header (e.g., extra compiler
  flags)

## Value

A named list of data frames with components: `functions`, `structs`,
`struct_members`, `enums`, `unions`, `globals`, `defines`.

## Details

This helper loops over headers found in a directory and returns a list
with tidy data.frames. Useful for programmatic analysis of header
collections.

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("treesitter", quietly = TRUE)) {
  res <- parse_headers_collect(dir = R.home("include"), preprocess = FALSE)
  head(res$functions)
}
} # }
```
