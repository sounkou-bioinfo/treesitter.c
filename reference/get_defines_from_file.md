# This function will use the configured C compiler to list macro definitions (`-dM -E`) if `use_cpp = TRUE` and a compiler is available; otherwise, a simple scan of `#define` lines is used as a fallback.

This function will use the configured C compiler to list macro
definitions (`-dM -E`) if `use_cpp = TRUE` and a compiler is available;
otherwise, a simple scan of `#define` lines is used as a fallback.

## Usage

``` r
get_defines_from_file(file, use_cpp = TRUE, cc = r_cc(), ccflags = NULL)
```

## Arguments

- file:

  Path to a header file

- use_cpp:

  Logical; use the C preprocessor if available

- cc:

  Compiler string; passed to `system2` if `use_cpp = TRUE`.

- ccflags:

  Additional flags for the compiler

## Value

Character vector of macro names defined in `file`
