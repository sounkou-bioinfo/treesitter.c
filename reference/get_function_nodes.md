# Extract function names (declarations and definitions) from a root

Returns a data frame with `capture_name`, `text`, `start_line`, and
`start_col`.

## Usage

``` r
get_function_nodes(root, extract_params = FALSE)
```

## Arguments

- root:

  A tree-sitter root node.

- extract_params:

  Logical; whether to extract parameter types for found functions.
  Default FALSE.

## Value

Data frame with function captures; when `extract_params=TRUE` a `params`
list-column is present.
