# Changelog

## treesitter.c 0.0.2.9000 (Development)

- Migrate from `testthat` to `tinytest`
- Basic parsing facilities of C headers
- Using r_cc for preprocessing
- Added pycparser’s fake_libc headers (Eli Bendersky and Co-authors) to
  inst/fake_libc for improved preprocessing of C headers with System
  headers bloat.
- Improve
  [`get_struct_members()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_struct_members.md)
  to assemble full member types (e.g., unsigned/qualified types)
- Include uninitialized globals in
  [`get_globals_from_root()`](https://sounkou-bioinfo.github.io/treesitter.c/reference/get_globals_from_root.md)

## treesitter.c 0.0.1 (CRAN Submission)

CRAN release: 2025-12-10

Initial CRAN submission
