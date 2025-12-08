# Run the C preprocessor on `file` using the provided compiler

This function runs the configured C compiler with the `-E` preprocessor
flag and returns the combined preprocessed output as a single string.

## Usage

``` r
preprocess_header(file, cc = r_cc(), ccflags = NULL)
```

## Arguments

- file:

  Path to a header file to preprocess.

- cc:

  (Character) Compiler command to use. If `NULL`, resolved via
  [`r_cc()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/r_cc.md).

- ccflags:

  (Character) Additional flags to pass to the compiler.

## Value

Character scalar with the preprocessed output of `file`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Check for a compiler before running an example that invokes the preprocessor
rcc <- treesitter.c::r_cc()
if (nzchar(rcc)) {
    rcc_prog <- strsplit(rcc, "\\s+")[[1]][1]
    if (nzchar(Sys.which(rcc_prog))) {
        tmp <- tempfile("hdr3")
        dir.create(tmp)
        path <- file.path(tmp, "p.h")
        writeLines(c("#define TYPE int", "TYPE foo(TYPE x);"), path)
        out <- preprocess_header(path)
        grepl("int foo\\(", out)
    } else {
        message("Skipping preprocess example: compiler not found on PATH")
    }
}
} # }
```
