# Preprocess a set of header files found under `dir`

This helper calls
[`preprocess_header()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/preprocess_header.md)
for each matching file in `dir` and returns a named list with the path
as the keys and the preprocessed text as the values.

## Usage

``` r
preprocess_headers(
  dir = R.home("include"),
  recursive = TRUE,
  pattern = c("\\.h$", "\\.H$"),
  cc = r_cc(),
  ccflags = NULL,
  ...
)
```

## Arguments

- dir:

  Directory where header files will be searched.

- recursive:

  Logical; whether to search recursively.

- pattern:

  File name pattern(s) used to identify header files.

- cc:

  Compiler string; passed to `preprocess_header`.

- ccflags:

  Compiler flags; passed to `preprocess_header`.

- ...:

  Arguments passed on to
  [`parse_r_include_headers`](https://sounkou-bioinfo.github.io/treesitter.c/reference/parse_r_include_headers.md)

  `preprocess`

  :   Run the C preprocessor (using R's configured CC) on header files
      before parsing. Defaults to `FALSE`.

  `include_dirs`

  :   Additional directories to add to the include path for
      preprocessing. A character vector of directories.

## Value

Named list of file =\> preprocessed text.
