# Test runner for bindgen (inline mode)
# 1. Generate C bindings from header examples
# 2. Compile generated C together with example implementations
# 3. Load shared object and run simple checks

## Prefer loading the package with devtools/pkgload rather than sourcing files.
devtools::load_all(".")


hdrs <- list.files("inst/examples/headers", full.names = TRUE, pattern = "\\.(h|hpp)$")
cat("Headers to parse:\n")
print(hdrs)

res <- generate_bindings(hdrs, out_c = "inst/examples/generated_bindings.c", mode = "inline", pkgname = "treesitter_c_gen", overwrite = TRUE)
cat("Generated", res$out_c, "\n")

# Compile: include our helper headers.
# Define the implementation .c files explicitly (these should contain the
# real implementations of the functions declared in the headers). Edit
# `impl_sources` below to point to your implementation sources. The
# generated bindings file (`generated_bindings.c`) is kept separate and is
# always included first in the build.
gen_c <- "inst/examples/generated_bindings.c"
impl_sources <- c(
    # examples; edit as needed
    "inst/examples/function_bindings.c",
    "inst/examples/array_structs.c",
    "inst/examples/enum_union.c"
)

# Verify implementations exist
missing_impls <- impl_sources[!file.exists(impl_sources)]
if (length(missing_impls) > 0) {
    stop(sprintf("Missing implementation .c files: %s\nPlease provide these files or update 'impl_sources' in inst/examples/test_bindgen.R to point to your implementation sources.", paste(missing_impls, collapse = ", ")))
}

# Build list: generated bindings first, then implementations
all_build <- c(if (file.exists(gen_c)) gen_c else character(0), impl_sources)
if (length(all_build) == 0) stop("No C sources available to build")

cmd <- sprintf("PKG_CPPFLAGS='-Iinst/include -Iinst/examples/headers' R CMD SHLIB %s", paste(shQuote(all_build), collapse = " "))
cat("Running:", cmd, "\n")
sys <- system(cmd)
if (sys != 0) stop("build failed")

so <- list.files("inst/examples", pattern = "\\.(so|dll|dylib)$", full.names = TRUE)[1]
cat("Built shared object:", so, "\n")

# quick checks in R
dyn.load(so)
# call add_ints using registered name and PACKAGE to avoid collision
cat(".Call wrap_treesitter_c_gen_add_ints(2,3) ->", .Call("add_ints", as.integer(2), as.integer(3), PACKAGE = "treesitter_c_gen"), "\n")

# create a Point via the wrapper constructor and read x (use PACKAGE)
p <- .Call("make_treesitter_c_gen_Point", PACKAGE = "treesitter_c_gen")
cat("Point.x =", .Call("get_treesitter_c_gen_Point_x", p, PACKAGE = "treesitter_c_gen"), "\n")


cat("Test bindgen done.\n")
