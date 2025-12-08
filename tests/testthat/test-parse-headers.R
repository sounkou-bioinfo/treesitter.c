test_that("parse_r_include_headers detects declarations and definitions", {
    tmp <- tempfile("hdr")
    dir.create(tmp)
    path <- file.path(tmp, "example.h")
    writeLines(
        c(
            "/* example header */",
            "int foo(int a);",
            "static inline int bar(void) { return 1; }",
            "struct S { int x; };",
            "int baz(void);"
        ),
        path
    )

    res <- parse_r_include_headers(dir = tmp, recursive = FALSE)
    expect_s3_class(res, "data.frame")
    expect_true(any(res$name == "foo" & res$kind == "declaration"))
    expect_true(any(res$name == "bar" & res$kind == "definition"))
    expect_true(any(res$name == "baz" & res$kind == "declaration"))
})

test_that("preprocessing uses R CMD config CC when requested", {
    # Skip if we have no compiler reported by R CMD config CC
    rcc_raw <- treesitter.c::r_cc()
    if (!nzchar(rcc_raw)) {
        skip("No C compiler from R CMD config CC; skipping preprocess test")
    }
    rcc_parts <- unlist(strsplit(rcc_raw, "\\s+"))
    rcc_prog <- rcc_parts[1]
    # Ensure the compiler itself is available on PATH (we don't care about MSVC), e.g. Rtools gcc
    if (!nzchar(Sys.which(rcc_prog))) {
        skip(paste0(
            "C compiler '",
            rcc_prog,
            "' not found on PATH; skipping preprocess test"
        ))
    }

    tmp <- tempfile("hdr2")
    dir.create(tmp)
    path <- file.path(tmp, "example2.h")
    writeLines(
        c(
            "#define TYPE int",
            "TYPE p(TYPE x);"
        ),
        path
    )
    res <- parse_r_include_headers(
        dir = tmp,
        recursive = FALSE,
        preprocess = TRUE
    )
    expect_true(nrow(res) >= 1)
})

test_that("parse_r_include_headers include_dirs preserves declarations (Rf names)", {
    rcc <- treesitter.c::r_cc()
    if (!nzchar(rcc)) skip("No C compiler; skipping preprocess include_dirs test")
    rcc_prog <- strsplit(rcc, "\\s+")[[1]][1]
    if (!nzchar(Sys.which(rcc_prog))) skip("C compiler not on PATH; skipping test")

    # Parse a system header with and without include_dirs; ensure preprocessed parse
    # includes expected Rf names when include_dirs are set.
    hdr_dir <- R.home("include")
    res_yes <- parse_r_include_headers(dir = hdr_dir, recursive = FALSE, preprocess = TRUE, include_dirs = hdr_dir)
    # Now we expect to find Rf_ names in the preprocessed results
    expect_true(any(grepl("Rf_initialize_R", res_yes$name) | grepl("Rf_initEmbeddedR", res_yes$name)))
})

test_that("preprocess_header returns preprocessed text", {
    rcc <- treesitter.c::r_cc()
    if (!nzchar(rcc)) {
        skip("No C compiler from R CMD config CC; skipping preprocess_header test")
    }
    rcc_parts <- unlist(strsplit(rcc, "\\s+"))
    rcc_prog <- rcc_parts[1]
    if (!nzchar(Sys.which(rcc_prog))) {
        skip(paste0("C compiler '", rcc_prog, "' not found on PATH; skipping preprocess_header test"))
    }
    tmp <- tempfile("hdr3")
    dir.create(tmp)
    path <- file.path(tmp, "p.h")
    writeLines(c("#define TYPE int", "TYPE foo(TYPE x);"), path)
    out <- preprocess_header(path)
    expect_true(grepl("int foo\\(", out))
})

test_that("get_function_nodes returns captures for functions", {
    tmp <- tempfile("hdr4")
    dir.create(tmp)
    path <- file.path(tmp, "f.h")
    writeLines(
        c("int foo(int a);", "static inline int bar(void) { return 1; }"),
        path
    )
    txt <- paste(readLines(path), collapse = "\n")
    root <- parse_header_text(txt)
    captures <- get_function_nodes(root)
    expect_true(is.data.frame(captures) && nrow(captures) >= 2)
    expect_true(any(
        captures$capture_name == "decl_name" & grepl("foo", captures$text)
    ))
})

test_that("get_defines_from_file parses #define macros", {
    tmp <- tempfile("hdr5")
    dir.create(tmp)
    path <- file.path(tmp, "d.h")
    writeLines(c("#define FOO 1", "# define BAR(x) (x)"), path)
    defs <- get_defines_from_file(path)
    expect_true(all(c("FOO", "BAR") %in% defs))
})

test_that("get_struct_nodes returns struct names", {
    tmp <- tempfile("hdr9")
    dir.create(tmp)
    path <- file.path(tmp, "s.h")
    writeLines(c("struct S { int x; };"), path)
    root <- parse_header_text(paste(readLines(path), collapse = "\n"))
    caps <- get_struct_nodes(root)
    expect_true(is.data.frame(caps) && any(grepl("S", caps$text)))
})

test_that("get_enum_nodes returns enum names", {
    tmp <- tempfile("hdr7")
    dir.create(tmp)
    path <- file.path(tmp, "e.h")
    writeLines(c("enum Color { RED, BLUE = 2, GREEN };"), path)
    root <- parse_header_text(paste(readLines(path), collapse = "\n"))
    caps <- get_enum_nodes(root)
    expect_true(is.data.frame(caps) && any(grepl("Color", caps$text)))
})

test_that("get_union_nodes returns union names", {
    tmp <- tempfile("hdr8")
    dir.create(tmp)
    path <- file.path(tmp, "u.h")
    writeLines(c("union U { int a; float b; };"), path)
    root <- parse_header_text(paste(readLines(path), collapse = "\n"))
    caps <- get_union_nodes(root)
    expect_true(is.data.frame(caps) && any(grepl("U", caps$text)))
})

test_that("get_struct_members detect bitfields", {
    tmp <- tempfile("hdr10")
    dir.create(tmp)
    path <- file.path(tmp, "s2.h")
    writeLines(
        c("struct B { unsigned int x:1; unsigned int y:4; int z; };"),
        path
    )
    root <- parse_header_text(paste(readLines(path), collapse = "\n"))
    members <- get_struct_members(root)
    expect_true(is.data.frame(members))
    expect_true(any(members$member_name == "x" & grepl("1", members$bitfield)))
    expect_true(any(members$member_name == "y" & grepl("4", members$bitfield)))
    expect_true(any(members$member_name == "z"))
    # No nested struct in this header
})

test_that("get_struct_members returns nested anonymous struct members", {
    tmp <- tempfile("hdr11")
    dir.create(tmp)
    path <- file.path(tmp, "s3.h")
    writeLines(
        c("struct Outer { struct { int a; int b:3; } inner; int c; };"),
        path
    )
    root <- parse_header_text(paste(readLines(path), collapse = "\n"))
    members <- get_struct_members(root)
    expect_true(is.data.frame(members))
    expect_true(any(
        members$member_name == "inner" & grepl("a", members$nested_members)
    ))
    expect_true(any(
        members$member_name == "inner" & grepl("b:3", members$nested_members)
    ))
    expect_true(any(members$member_name == "c"))
})

test_that("get_defines_from_file uses preprocessor when available", {
    rcc <- treesitter.c::r_cc()
    if (!nzchar(rcc)) {
        skip("No C compiler; skipping preprocessor test")
    }

    tmp <- tempfile("hdr6")
    dir.create(tmp)
    path <- file.path(tmp, "defs.h")
    writeLines(c("#define FOO 1", "#define BAR(x) (x)"), path)
    defs_cpp <- get_defines_from_file(path, use_cpp = TRUE)
    expect_true(all(c("FOO", "BAR") %in% defs_cpp))
})

test_that("parse_headers_collect returns combined results", {
    tmp <- tempfile("hdr_collect")
    dir.create(tmp)
    path <- file.path(tmp, "example.h")
    writeLines(
        c("struct T { int a; };", "int foo(int x);", "#define TEST 1"),
        path
    )
    res <- parse_headers_collect(dir = tmp, preprocess = FALSE)
    expect_true(is.list(res))
    expect_true("functions" %in% names(res))
    expect_true("structs" %in% names(res))
    expect_true(any(grepl("foo", res$functions$name)))
    expect_true(any(grepl("T", res$structs$text)))
})

test_that("get_function_nodes extract_params works", {
    tmp <- tempfile("hdr_fn")
    dir.create(tmp)
    path <- file.path(tmp, "fn.h")
    writeLines(c("int foo(int a, const char* s);"), path)
    txt <- paste(readLines(path), collapse = "\n")
    root <- parse_header_text(txt)
    caps <- get_function_nodes(root, extract_params = TRUE)
    expect_true(is.data.frame(caps))
    expect_true("params" %in% colnames(caps))
    # params is stored as list-column; ensure it contains the two param types
    expect_true(length(caps$params[[1]]) >= 2)
})
