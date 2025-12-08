# Return the default R-configured C compiler (possibly with flags)

This function queries common places to find the C compiler used by R. It
checks Sys.getenv("CC"), then `R CMD config CC`, and finally `cc` on
PATH. The returned value may include flags (e.g., 'gcc -std=...').

## Usage

``` r
r_cc()
```

## Value

Character scalar with compiler program (or empty string).
