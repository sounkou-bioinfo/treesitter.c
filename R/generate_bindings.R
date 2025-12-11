## Generic binding generator using treesitter metadata
## This implementation is generic (no example-specific names), prefixes all
## generated symbols using a sanitized `pkgname`, and provides raw field
## accessors for structs so arbitrary headers can be targeted.

sanitize_prefix <- function(x) {
    y <- gsub("[^A-Za-z0-9_]", "_", x)
    if (nchar(y) == 0) y <- "bindgen"
    y
}

make_c_for_function <- function(f, prefix) {
    name <- f$name
    ret <- f$ret
    params <- f$params
    if (is.null(params)) param_list <- character(0) else if (is.character(params) && length(params) > 1) param_list <- params else if (is.character(params) && length(params) == 1) param_list <- if (nchar(params) == 0) character(0) else strsplit(params, ",")[[1]] else param_list <- character(0)
    param_names <- vapply(seq_along(param_list), function(i) paste0("s_arg", i), "")
    args_sig <- paste(sprintf("SEXP %s", param_names), collapse = ", ")
    c_names <- vapply(seq_along(param_list), function(i) paste0("arg", i), "")

    # detect pointer+length adjacent pairs and generate conversions accordingly
    n <- length(param_list)
    used <- rep(FALSE, n)
    conv_lines <- character(0)
    for (i in seq_len(n)) {
        if (used[i]) next
        p <- trimws(param_list[[i]])
        if (grepl("\\*", p) && i < n) {
            # candidate for pointer+length pair if next param is size/int-like
            pnext <- trimws(param_list[[i + 1]])
            if (grepl("\b(size_t|ssize_t|int|unsigned|long|ptrdiff_t)\b", pnext)) {
                # treat as pointer + length
                if (grepl("double", p)) {
                    conv_lines <- c(conv_lines, sprintf("CHECK_SEXP_TYPE(%s, REALSXP); double *%s = REAL(%s); size_t %s_len = (size_t) r_to_c_int_na(%s, NULL, NULL);", param_names[i], c_names[i], param_names[i], c_names[i], param_names[i + 1]))
                } else {
                    conv_lines <- c(conv_lines, sprintf("void *%s = r_to_c_ptr_checked(%s, NULL); size_t %s_len = (size_t) r_to_c_int_na(%s, NULL, NULL);", c_names[i], param_names[i], c_names[i], param_names[i + 1]))
                }
                used[i + 1] <- TRUE
                next
            }
        }
        # normal single param conversion
        if (grepl("\\*", p)) {
            if (grepl("double", p)) {
                conv_lines <- c(conv_lines, sprintf("CHECK_SEXP_TYPE(%s, REALSXP); double *%s = REAL(%s); size_t %s_len = (size_t) length(%s);", param_names[i], c_names[i], param_names[i], c_names[i], param_names[i]))
            } else {
                conv_lines <- c(conv_lines, sprintf("void *%s = r_to_c_ptr_checked(%s, NULL);", c_names[i], param_names[i]))
            }
        } else if (grepl("int|char|short|long|size_t|unsigned", p)) {
            conv_lines <- c(conv_lines, sprintf("int %s = r_to_c_int_na(%s, NULL, NULL);", c_names[i], param_names[i]))
        } else if (grepl("double|float", p)) {
            conv_lines <- c(conv_lines, sprintf("double %s = r_to_c_double_na(%s, NULL, NULL);", c_names[i], param_names[i]))
        } else {
            conv_lines <- c(conv_lines, sprintf("void *%s = r_to_c_ptr_checked(%s, NULL);", c_names[i], param_names[i]))
        }
    }

    # call args: skip length parameters that were consumed
    call_args_items <- character(0)
    i <- 1
    while (i <= n) {
        if (used[i]) {
            i <- i + 1
            next
        }
        p <- trimws(param_list[[i]])
        if (grepl("\\*", p) && i < n && used[i + 1]) {
            # pointer + length pair generated earlier
            call_args_items <- c(call_args_items, sprintf("%s, %s_len", c_names[i], c_names[i]))
            i <- i + 2
            next
        }
        if (grepl("int|char|short|long|unsigned|size_t", p)) {
            call_args_items <- c(call_args_items, sprintf("(%s)", c_names[i]))
        } else if (grepl("double|float", p)) {
            call_args_items <- c(call_args_items, sprintf("(%s)", c_names[i]))
        } else if (grepl("\\*", p)) {
            call_args_items <- c(call_args_items, c_names[i])
        } else {
            call_args_items <- c(call_args_items, c_names[i])
        }
        i <- i + 1
    }
    convs <- conv_lines
    call_args <- paste(call_args_items, collapse = ", ")

    # build wrapper
    wrapper_name <- sprintf("wrap_%s_%s", prefix, name)
    if (grepl("void", ret)) {
        ret_code <- sprintf("%s(%s);\n  return R_NilValue;", name, call_args)
    } else if (grepl("double|float", ret)) {
        ret_code <- sprintf("double __res = %s(%s);\n  return ScalarReal(__res);", name, call_args)
    } else {
        ret_code <- sprintf("int __res = %s(%s);\n  return ScalarInteger(__res);", name, call_args)
    }
    sprintf("SEXP %s(%s) {\n  %s\n  %s\n}\n", wrapper_name, args_sig, paste(convs, collapse = "\n  "), ret_code)
}

make_c_for_struct <- function(s, prefix) {
    name <- s$name
    members <- s$members
    # constructor that zero-inits
    cons <- sprintf("SEXP make_%s_%s() { struct %s *p = (struct %s*) calloc(1, sizeof(struct %s)); if (!p) error(\"alloc failed\"); SEXP ext = R_MakeExternalPtr(p, R_NilValue, R_NilValue); R_RegisterCFinalizer(ext, finalize_%s); return ext; }\n", prefix, name, name, name, name, prefix)
    body <- cons
    # typed accessor lists for registration
    typed_gets <- character(0)
    typed_sets <- character(0)

    if (!is.null(members) && length(members) > 0) {
        # getter by name -> returns raw vector of bytes for the field
        get_header <- sprintf("SEXP get_%s_%s_field(SEXP ext, SEXP sname) { struct %s *p = (struct %s*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));\n", prefix, name, name, name)
        get_cases <- character(0)
        set_cases <- character(0)
        for (entry in members) {
            m <- entry$name
            if (is.na(m) || nchar(m) == 0) next
            mbits <- entry$bitfield
            if (!is.na(mbits)) {
                # bitfield: use bitfield helpers
                get_cases <- c(get_cases, sprintf("  if (strcmp(name, \"%s\")==0) { uint64_t v = GET_BITFIELD_AS_UINT64(p, BITOFFSET(struct %s, %s), BITSIZE(struct %s, %s)); return ScalarReal((double)v); }", m, name, m, name, m))
                set_cases <- c(set_cases, sprintf("  if (strcmp(name, \"%s\")==0) { int __ok=0; SET_BITFIELD_FROM_SEXP(p, BITOFFSET(struct %s, %s), BITSIZE(struct %s, %s), raw, __ok); if (!__ok) error(\"set_%s_%s_field: conversion failed\"); return R_NilValue; }", m, name, m, name, m, prefix, name))
            } else {
                # plain member: copy raw bytes
                get_cases <- c(get_cases, sprintf("  if (strcmp(name, \"%s\")==0) { size_t sz = sizeof(((struct %s*)0)->%s); SEXP out = PROTECT(allocVector(RAWSXP, (R_xlen_t)sz)); memcpy(RAW(out), (char*)p + FIELD_OFFSET(struct %s, %s), sz); UNPROTECT(1); return out; }", m, name, m, name, m))
                set_cases <- c(set_cases, sprintf("  if (strcmp(name, \"%s\")==0) { if (TYPEOF(raw) != RAWSXP) error(\"set_%s_%s_field: raw required\"); size_t sz = sizeof(((struct %s*)0)->%s); if ((size_t) LENGTH(raw) != sz) error(\"set_%s_%s_field: wrong size\"); write_field_unaligned((char*)p + FIELD_OFFSET(struct %s, %s), RAW(raw), sz); return R_NilValue; }", m, prefix, name, name, m, prefix, name, name, m))
                # if we have a typed member (member$type present) generate typed get/set
                if (!is.null(entry$type) && !is.na(entry$type) && nzchar(entry$type)) {
                    # choose C type and conversion helpers
                    mtype <- tolower(entry$type)
                    if (grepl("double", mtype)) {
                        ctype <- "double"
                        get_inner <- sprintf("%s tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct %s, %s), sizeof(%s)); return ScalarReal(tmp);", ctype, name, m, ctype)
                        set_inner <- sprintf("int __isna=0, __ok=0; double __v = r_to_c_double_na(val, &__isna, &__ok); if (!__ok) error(\"set_%s_%s_field: bad value\"); write_field_unaligned((char*)p + FIELD_OFFSET(struct %s, %s), &__v, sizeof(%s)); return R_NilValue;", prefix, name, name, m, ctype)
                    } else if (grepl("float", mtype)) {
                        ctype <- "float"
                        get_inner <- sprintf("%s tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct %s, %s), sizeof(%s)); return ScalarReal((double)tmp);", ctype, name, m, ctype)
                        set_inner <- sprintf("int __isna=0, __ok=0; double __dv = r_to_c_double_na(val, &__isna, &__ok); if (!__ok) error(\"set_%s_%s_field: bad value\"); %s __v = (%s)__dv; write_field_unaligned((char*)p + FIELD_OFFSET(struct %s, %s), &__v, sizeof(%s)); return R_NilValue;", prefix, name, ctype, ctype, name, m, ctype)
                    } else if (grepl("_?bool|_?Bool", mtype)) {
                        ctype <- "int"
                        get_inner <- sprintf("%s tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct %s, %s), sizeof(%s)); return ScalarLogical(tmp ? 1 : 0);", ctype, name, m, ctype)
                        set_inner <- sprintf("int __isna=0, __ok=0; int __v = r_to_c_bool_na(val, &__isna, &__ok); if (!__ok) error(\"set_%s_%s_field: bad value\"); write_field_unaligned((char*)p + FIELD_OFFSET(struct %s, %s), &__v, sizeof(%s)); return R_NilValue;", prefix, name, name, m, ctype)
                    } else {
                        # default to integer conversion
                        ctype <- "int"
                        get_inner <- sprintf("%s tmp; read_field_unaligned(&tmp, (char*)p + FIELD_OFFSET(struct %s, %s), sizeof(%s)); return ScalarInteger(tmp);", ctype, name, m, ctype)
                        set_inner <- sprintf("int __isna=0, __ok=0; int __v = r_to_c_int_na(val, &__isna, &__ok); if (!__ok) error(\"set_%s_%s_field: bad value\"); write_field_unaligned((char*)p + FIELD_OFFSET(struct %s, %s), &__v, sizeof(%s)); return R_NilValue;", prefix, name, name, m, ctype)
                    }
                    # emit full functions with proper pointer retrieval and parameter names
                    typed_gets <- c(typed_gets, sprintf("SEXP get_%s_%s_%s(SEXP ext, SEXP raw_unused) { struct %s *p = (struct %s*) r_to_c_ptr_checked(ext, NULL); %s }", prefix, name, m, name, name, get_inner))
                    typed_sets <- c(typed_sets, sprintf("SEXP set_%s_%s_%s(SEXP ext, SEXP val) { struct %s *p = (struct %s*) r_to_c_ptr_checked(ext, NULL); %s }", prefix, name, m, name, name, set_inner))
                }
            }
        }
        get_footer <- "  error(\"unknown field\"); }\n"
        get_fn <- paste0(get_header, paste(get_cases, collapse = "\n  "), "\n", get_footer)
        set_header <- sprintf("SEXP set_%s_%s_field(SEXP ext, SEXP sname, SEXP raw) { struct %s *p = (struct %s*) r_to_c_ptr_checked(ext, NULL); const char *name = CHAR(STRING_ELT(sname,0));\n", prefix, name, name, name)
        set_fn <- paste0(set_header, paste(set_cases, collapse = "\n  "), "\n  error(\"unknown field\"); return R_NilValue; }\n")
        body <- paste0(body, "\n", get_fn, "\n", set_fn)
        if (length(typed_gets) > 0) body <- paste0(body, "\n", paste(typed_gets, collapse = "\n"), "\n")
        if (length(typed_sets) > 0) body <- paste0(body, paste(typed_sets, collapse = "\n"), "\n")
    }
    body
}

#' Generate minimal C bindings from C headers
#'
#' Generic generator: prefixes generated symbols using `pkgname` so the
#' output is safe to compile alongside existing example sources. It returns
#' the generated C path and a suggested `PKG_CPPFLAGS` value when
#' `include_dirs` is provided.
#'
#' @param headers Character vector of header file paths, or a single directory containing headers.
#' @param out_c Path to write generated C file.
#' @param mode One of "inline" or "package".
#' @param pkgname Package name used for registration symbol generation and prefixing.
#' @param include_dirs Optional vector of include directories to suggest for compilation (returned in result).
#' @param overwrite If TRUE overwrite existing `out_c`.
#' @return Invisibly returns a list with `out_c`, `funcs`, `structs`, and `cppflags` (suggested include flags).
#' @export
generate_bindings <- function(headers, out_c = "inst/examples/generated_bindings.c", mode = c("inline", "package"), pkgname = "treesitter_c_gen", include_dirs = NULL, overwrite = FALSE) {
    mode <- match.arg(mode)
    prefix <- sanitize_prefix(pkgname)

    if (file.exists(out_c) && !overwrite) stop("output file exists; set overwrite = TRUE to replace")

    if (length(headers) == 1L && dir.exists(headers)) {
        parsed <- parse_headers_collect(dir = headers, preprocess = FALSE, extract_params = TRUE, extract_return = TRUE)
    } else {
        tmp <- tempfile("bindgen_hdrs")
        dir.create(tmp)
        for (h in headers) file.copy(h, file.path(tmp, basename(h)))
        parsed <- parse_headers_collect(dir = tmp, preprocess = FALSE, extract_params = TRUE, extract_return = TRUE)
    }

    funcs_df <- parsed$functions
    structs_df <- parsed$structs

    includes <- character(0)
    if (length(headers) == 1L && dir.exists(headers)) {
        hs <- list.files(headers, pattern = "\\.h$", full.names = FALSE)
        includes <- paste0('#include "', hs, '"')
    } else {
        bas <- vapply(headers, basename, "")
        includes <- paste0('#include "', bas, '"')
    }

    lines <- c("#include <R.h>", "#include <Rinternals.h>", "#include <stddef.h>", "#include <stdint.h>", includes, '#include "treesitter.c/RCffi_helper.h"', '#include "treesitter.c/offsets.h"', "#include <stdlib.h>", "")

    # unique static finalizer used for all external pointers in this generated file
    lines <- c(lines, sprintf("static void finalize_%s(SEXP ext) { void *p = R_ExternalPtrAddr(ext); if (p) free(p); }", prefix), "")

    generated_funcs <- character(0)
    generated_structs <- character(0)

    if (nrow(funcs_df) > 0) {
        for (i in seq_len(nrow(funcs_df))) {
            fname <- funcs_df$name[i]
            f <- list(name = fname, ret = funcs_df$return_type[i], params = if (!is.null(funcs_df$params[[i]])) funcs_df$params[[i]] else character(0))
            fc <- make_c_for_function(f, prefix)
            lines <- c(lines, fc, "")
            generated_funcs <- c(generated_funcs, fname)
        }
    }

    members_map <- list()
    if (!is.null(parsed$struct_members) && nrow(parsed$struct_members) > 0) {
        sm <- parsed$struct_members
        for (i in seq_len(nrow(sm))) {
            sname <- as.character(sm$struct_name[i])
            if (is.na(sname) || nchar(sname) == 0) next
            mname <- as.character(sm$member_name[i])
            mtype <- if (!is.null(sm$member_type)) as.character(sm$member_type[i]) else NA_character_
            mbits <- if (!is.null(sm$bitfield)) sm$bitfield[i] else NA_integer_
            nested <- if (!is.null(sm$nested_members)) as.character(sm$nested_members[i]) else NA_character_
            entry <- list(name = mname, type = mtype, bitfield = mbits, nested = nested)
            members_map[[sname]] <- c(members_map[[sname]], list(entry))
        }
    }

    if (nrow(structs_df) > 0) {
        for (i in seq_len(nrow(structs_df))) {
            sname <- structs_df$text[i]
            s_members <- if (!is.null(members_map[[sname]])) members_map[[sname]] else NULL
            s <- list(name = sname, members = s_members)
            sc <- make_c_for_struct(s, prefix)
            lines <- c(lines, sc, "")
            generated_structs <- c(generated_structs, sname)
        }
    }

    # registration: register R-visible names as original names but point to prefixed wrappers
    call_entries <- character(0)
    if (length(generated_funcs) > 0) {
        for (nm in generated_funcs) {
            row <- which(funcs_df$name == nm)[1]
            pvec <- funcs_df$params[[row]]
            if (is.null(pvec)) {
                nparams <- 0L
            } else if (is.character(pvec) && length(pvec) > 1) {
                nparams <- length(pvec)
            } else if (is.character(pvec) && length(pvec) == 1) {
                nparams <- if (nchar(pvec) == 0) 0L else length(strsplit(pvec, ",")[[1]])
            } else {
                nparams <- 0L
            }
            call_entries <- c(call_entries, sprintf('  {"%s", (DL_FUNC) &wrap_%s_%s, %d},', nm, prefix, nm, nparams))
        }
    }
    if (length(generated_structs) > 0) {
        for (sname in generated_structs) {
            call_entries <- c(call_entries, sprintf('  {"make_%s", (DL_FUNC) &make_%s_%s, 0},', sname, prefix, sname))
            call_entries <- c(call_entries, sprintf('  {"get_%s_field", (DL_FUNC) &get_%s_%s_field, 2},', sname, prefix, sname))
            call_entries <- c(call_entries, sprintf('  {"set_%s_field", (DL_FUNC) &set_%s_%s_field, 3},', sname, prefix, sname))
            # register typed accessors if present
            # typed names produced are get_<prefix>_<Struct>_<field> and set_<prefix>_<Struct>_<field>
            # Find members for this struct from members_map
            members <- members_map[[sname]]
            if (!is.null(members) && length(members) > 0) {
                for (entry in members) {
                    m <- entry$name
                    if (is.na(m) || !nzchar(m)) next
                    # only register typed accessors when the member has a known type
                    if (!is.null(entry$type) && !is.na(entry$type) && nzchar(entry$type)) {
                        call_entries <- c(call_entries, sprintf('  {"get_%s_%s", (DL_FUNC) &get_%s_%s_%s, 1},', sname, m, prefix, sname, m))
                        call_entries <- c(call_entries, sprintf('  {"set_%s_%s", (DL_FUNC) &set_%s_%s_%s, 2},', sname, m, prefix, sname, m))
                    }
                }
            }
        }
    }

    lines <- c(
        lines, "static const R_CallMethodDef callMethods[] = {", call_entries, "  {NULL, NULL, 0}", "};",
        sprintf("void R_init_%s(DllInfo *dll) {", pkgname),
        "  R_registerRoutines(dll, NULL, callMethods, NULL, NULL);",
        "  R_useDynamicSymbols(dll, TRUE);",
        "  R_forceSymbols(dll, TRUE);",
        "}"
    )

    dir.create(dirname(out_c), showWarnings = FALSE, recursive = TRUE)
    writeLines(lines, out_c)
    cppflags <- if (!is.null(include_dirs) && length(include_dirs) > 0) paste0("-I", paste(include_dirs, collapse = " -I")) else NULL
    invisible(list(out_c = out_c, funcs = funcs_df, structs = structs_df, cppflags = cppflags))
}
