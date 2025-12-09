# Package index

## All functions

- [`fake_libc_path()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/fake_libc_path.md)
  : Get the path to the installed fake_libc headers

- [`get_defines_from_file()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_defines_from_file.md)
  :

  This function will use the configured C compiler to list macro
  definitions (`-dM -E`) if `use_cpp = TRUE` and a compiler is
  available; otherwise, a simple scan of `#define` lines is used as a
  fallback.

- [`get_enum_nodes()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_enum_nodes.md)
  : Extract enum names from a parsed header

- [`get_function_nodes()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_function_nodes.md)
  : Extract function names (declarations and definitions) from a root

- [`get_globals_from_root()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_globals_from_root.md)
  : Extract global variable names from a parsed tree root

- [`get_struct_members()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_struct_members.md)
  : Extract members of structs (including nested anonymous struct
  members)

- [`get_struct_nodes()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_struct_nodes.md)
  : Extract struct names from a parsed tree root

- [`get_union_nodes()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_union_nodes.md)
  : Extract union names from a parsed header

- [`language()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/language.md)
  : tree-sitter language for C

- [`parse_header_text()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/parse_header_text.md)
  : Convert character content of a header file into a tree-sitter root

- [`parse_headers_collect()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/parse_headers_collect.md)
  : Parse a directory of headers and return named list of data.frames
  with

- [`parse_r_include_headers()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/parse_r_include_headers.md)
  : Parse C header files for function declarations using tree-sitter

- [`preprocess_header()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/preprocess_header.md)
  :

  Run the C preprocessor on `file` using the provided compiler

- [`preprocess_headers()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/preprocess_headers.md)
  :

  Preprocess a set of header files found under `dir`

- [`r_cc()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/r_cc.md)
  : Return the default R-configured C compiler (possibly with flags)
