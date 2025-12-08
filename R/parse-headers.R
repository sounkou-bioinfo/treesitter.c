## Parse helpers for C header parsing (main doc moved to `parse_r_include_headers`)
#' Return the default R-configured C compiler (possibly with flags)
#'
#' This function queries common places to find the C compiler used by R.
#' It checks Sys.getenv("CC"), then `R CMD config CC`, and finally `cc` on PATH.
#' The returned value may include flags (e.g., 'gcc -std=...').
#'
#' @return Character scalar with compiler program (or empty string).
#' @export
r_cc <- function() {
    envcc <- Sys.getenv("CC")
    if (nzchar(envcc)) {
        return(envcc)
    }
    # Prefer using the R binary from R.home('bin') to avoid depending on PATH
    rprog <- file.path(R.home("bin"), "R")
    if (file.exists(rprog) && file.access(rprog, 1) == 0) {
        out <- tryCatch(
            suppressWarnings(system2(rprog, c("CMD", "config", "CC"), stdout = TRUE, stderr = FALSE)),
            error = function(e) NULL
        )
        if (!is.null(out) && length(out) > 0 && nzchar(out)) {
            return(out)
        }
    }
    found <- Sys.which("cc")
    if (nzchar(found)) {
        return(found)
    }
    ""
}

#' Return default C flags used by R
#' @noRd
r_ccflags <- function() {
    rprog <- file.path(R.home("bin"), "R")
    cflags <- tryCatch(
        {
            if (file.exists(rprog) && file.access(rprog, 1) == 0) {
                suppressWarnings(system2(rprog, c("CMD", "config", "CFLAGS"), stdout = TRUE, stderr = FALSE))
            } else {
                ""
            }
        },
        error = function(e) ""
    )
    cppflags <- tryCatch(
        {
            if (file.exists(rprog) && file.access(rprog, 1) == 0) {
                suppressWarnings(system2(rprog, c("CMD", "config", "CPPFLAGS"), stdout = TRUE, stderr = FALSE))
            } else {
                ""
            }
        },
        error = function(e) ""
    )
    paste(c(cflags, cppflags), collapse = " ")
}

#' Run the C preprocessor on `file` using the provided compiler
#'
#' This function runs the configured C compiler with the `-E` preprocessor
#' flag and returns the combined preprocessed output as a single string.
#'
#' @param file Path to a header file to preprocess.
#' @param cc (Character) Compiler command to use. If `NULL`, resolved via `r_cc()`.
#' @param ccflags (Character) Additional flags to pass to the compiler.
#' @return Character scalar with the preprocessed output of `file`.
#' @examples
#' \dontrun{
#' # Check for a compiler before running an example that invokes the preprocessor
#' rcc <- treesitter.c::r_cc()
#' if (nzchar(rcc)) {
#'     rcc_prog <- strsplit(rcc, "\\s+")[[1]][1]
#'     if (nzchar(Sys.which(rcc_prog))) {
#'         tmp <- tempfile("hdr3")
#'         dir.create(tmp)
#'         path <- file.path(tmp, "p.h")
#'         writeLines(c("#define TYPE int", "TYPE foo(TYPE x);"), path)
#'         out <- preprocess_header(path)
#'         grepl("int foo\\(", out)
#'     } else {
#'         message("Skipping preprocess example: compiler not found on PATH")
#'     }
#' }
#' }
#' @export
preprocess_header <- function(file, cc = r_cc(), ccflags = NULL) {
    if (!nzchar(file) || !file.exists(file)) {
        stop("`file` must point to an existing path")
    }
    # Split cc into program and args (user may supply 'gcc -std=...' as cc)
    cc_raw <- cc
    cc_parts <- if (nzchar(cc_raw)) {
        unlist(strsplit(cc_raw, "\\s+"))
    } else {
        character(0)
    }
    cc_prog <- if (length(cc_parts) >= 1) cc_parts[1] else ""
    cc_prog_args <- if (length(cc_parts) >= 2) cc_parts[-1] else character(0)
    if (!nzchar(cc_prog)) {
        stop("No C compiler configured; set `cc`")
    }

    if (is.null(ccflags) || !nzchar(ccflags)) {
        ccflags <- r_ccflags()
    }
    flags <- if (nzchar(ccflags)) {
        unlist(strsplit(ccflags, "\\s+"))
    } else {
        character(0)
    }
    args <- c(cc_prog_args, flags, "-E", file)
    preprocessed <- tryCatch(
        suppressWarnings(system2(cc_prog, args, stdout = TRUE, stderr = TRUE)),
        error = function(e) stop("Failed to run preprocessor: ", e$message)
    )
    if (is.null(preprocessed) || length(preprocessed) == 0) {
        stop("Failed to run preprocessor for: ", file)
    }
    paste(preprocessed, collapse = "\n")
}

#' Preprocess a set of header files found under `dir`
#'
#' This helper calls `preprocess_header()` for each matching file in
#' `dir` and returns a named list with the path as the keys and the
#' preprocessed text as the values.
#'
#' @param dir Directory where header files will be searched.
#' @param recursive Logical; whether to search recursively.
#' @param pattern File name pattern(s) used to identify header files.
#' @param cc Compiler string; passed to `preprocess_header`.
#' @param ccflags Compiler flags; passed to `preprocess_header`.
#' @return Named list of file => preprocessed text.
#' @export
preprocess_headers <- function(
  dir = R.home("include"),
  recursive = TRUE,
  pattern = c("\\.h$", "\\.H$"),
  cc = r_cc(),
  ccflags = NULL
) {
    files <- list.files(
        dir,
        pattern = paste0("(", paste(pattern, collapse = "|"), ")"),
        full.names = TRUE,
        recursive = recursive
    )
    out <- list()
    for (f in files) {
        flags <- if (is.null(ccflags) || !nzchar(ccflags)) r_ccflags() else ccflags
        out[[f]] <- preprocess_header(f, cc = cc, ccflags = flags)
    }
    out
}

#' Convert character content of a header file into a tree-sitter root
#'
#' @param text Character scalar with the header content to parse.
#' @param lang tree-sitter language object (default: C language from package)
#' @return The tree root node object
#' @examples
#' if (requireNamespace("treesitter", quietly = TRUE)) {
#'     root <- parse_header_text("int foo(int);\n")
#'     root
#' }
#' @export
parse_header_text <- function(text, lang = language()) {
    if (!requireNamespace("treesitter", quietly = TRUE)) {
        stop("treesitter required")
    }
    p <- treesitter::parser(lang)
    tree <- treesitter::parser_parse(p, text)
    root <- treesitter::tree_root_node(tree)
    root
}

#' Walk a tree recursively and call 'visitor(node, parents)' for each node
#' @noRd
walk_tree <- function(node, visitor, parents = list()) {
    visitor(node, parents)
    nc <- treesitter::node_child_count(node)
    if (nc > 0) {
        for (i in seq_len(nc)) {
            child <- treesitter::node_child(node, i)
            walk_tree(child, visitor, c(parents, list(node)))
        }
    }
}

#' Find descendant nodes of the root that match a given node type
#' @noRd
find_nodes_by_type <- function(root, types) {
    out <- list()
    visitor <- function(node, parents) {
        if (treesitter::node_type(node) %in% types) {
            out[[length(out) + 1L]] <<- node
        }
    }
    walk_tree(root, visitor)
    out
}

#' Find descendant nodes (within 'root') that match any of the 'types'
#' @noRd
find_descendants_by_type <- function(root, types) {
    out <- list()
    visitor <- function(node, parents) {
        if (treesitter::node_type(node) %in% types) out[[length(out) + 1L]] <<- node
    }
    walk_tree(root, visitor)
    out
}

#' Find the first child node of 'node' with type matching 'type'
#' @noRd
find_child_of_type <- function(node, type) {
    nc <- treesitter::node_child_count(node)
    if (nc < 1) {
        return(NULL)
    }
    for (i in seq_len(nc)) {
        ch <- treesitter::node_child(node, i)
        if (treesitter::node_type(ch) == type) {
            return(ch)
        }
    }
    NULL
}

#' Convert captures result from treesitter::query_captures into a data.frame
#' @noRd
captures_to_df <- function(captures) {
    # Convert the result of treesitter::query_captures to a data.frame with fields:
    # capture_name, text, start_line, start_col, end_line, end_col, node (AsIs list)
    if (is.null(captures)) {
        return(data.frame(
            capture_name = character(0),
            text = character(0),
            start_line = integer(0),
            start_col = integer(0),
            end_line = integer(0),
            end_col = integer(0),
            stringsAsFactors = FALSE
        ))
    }

    # handles list that has list$name and list$node
    if (
        is.list(captures) &&
            !is.data.frame(captures) &&
            all(c("name", "node") %in% names(captures))
    ) {
        n <- length(captures$name)
        capture_name <- captures$name
        text <- character(n)
        start_line <- integer(n)
        start_col <- integer(n)
        end_line <- integer(n)
        end_col <- integer(n)
        for (i in seq_len(n)) {
            node <- captures$node[[i]]
            # if it's a valid tree_sitter_node, extract text/positions; otherwise NA
            if (inherits(node, "tree_sitter_node")) {
                text[i] <- treesitter::node_text(node)
                sp <- treesitter::node_start_point(node)
                ep <- treesitter::node_end_point(node)
                # node_start_point returns numeric vector or list with 'row' & 'column'
                if (!is.null(sp)) {
                    if (is.numeric(sp) && length(sp) >= 2) {
                        start_line[i] <- as.integer(sp[1] + 1L)
                        start_col[i] <- as.integer(sp[2] + 1L)
                    } else if (is.list(sp) && ("row" %in% names(sp))) {
                        start_line[i] <- as.integer(sp$row + 1L)
                        start_col[i] <- as.integer(sp$column + 1L)
                    } else {
                        start_line[i] <- NA_integer_
                        start_col[i] <- NA_integer_
                    }
                } else {
                    start_line[i] <- NA_integer_
                    start_col[i] <- NA_integer_
                }
                if (!is.null(ep)) {
                    if (is.numeric(ep) && length(ep) >= 2) {
                        end_line[i] <- as.integer(ep[1] + 1L)
                        end_col[i] <- as.integer(ep[2] + 1L)
                    } else if (is.list(ep) && ("row" %in% names(ep))) {
                        end_line[i] <- as.integer(ep$row + 1L)
                        end_col[i] <- as.integer(ep$column + 1L)
                    } else {
                        end_line[i] <- NA_integer_
                        end_col[i] <- NA_integer_
                    }
                } else {
                    end_line[i] <- NA_integer_
                    end_col[i] <- NA_integer_
                }
            } else {
                text[i] <- NA_character_
                start_line[i] <- NA_integer_
                start_col[i] <- NA_integer_
                end_line[i] <- NA_integer_
                end_col[i] <- NA_integer_
            }
        }
        df <- data.frame(
            capture_name = capture_name,
            text = text,
            start_line = start_line,
            start_col = start_col,
            end_line = end_line,
            end_col = end_col,
            stringsAsFactors = FALSE
        )
        # Keep the node list in case callers want to inspect the nodes directly
        df$node <- I(captures$node)
        return(df)
    }

    # if already a data.frame try to normalize to the same fields
    if (is.data.frame(captures)) {
        df <- captures
        if ("name" %in% colnames(df) && !"capture_name" %in% colnames(df)) {
            df$capture_name <- df$name
        }
        if (!"text" %in% colnames(df)) {
            df$text <- NA_character_
        }
        if (!"start_line" %in% colnames(df)) {
            df$start_line <- NA_integer_
        }
        if (!"start_col" %in% colnames(df)) {
            df$start_col <- NA_integer_
        }
        if (!"end_line" %in% colnames(df)) {
            df$end_line <- NA_integer_
        }
        if (!"end_col" %in% colnames(df)) {
            df$end_col <- NA_integer_
        }
        if (!"node" %in% colnames(df)) {
            df$node <- I(list())
        }
        return(df[c(
            "capture_name",
            "text",
            "start_line",
            "start_col",
            "end_line",
            "end_col",
            "node"
        )])
    }

    # Otherwise return empty
    data.frame(
        capture_name = character(0),
        text = character(0),
        start_line = integer(0),
        start_col = integer(0),
        end_line = integer(0),
        end_col = integer(0),
        stringsAsFactors = FALSE
    )
}

#' Extract function names (declarations and definitions) from a root
#'
#' Returns a data frame with `capture_name`, `text`, `start_line`,
#' and `start_col`.
#' @param root A tree-sitter root node.
#' @param extract_params Logical; whether to extract parameter types for found functions. Default FALSE.
#' @return Data frame with function captures; when `extract_params=TRUE` a `params` list-column is present.
#' @export
get_function_nodes <- function(root, extract_params = FALSE, extract_return = FALSE) {
    nodes <- find_nodes_by_type(root, c("function_definition", "declaration"))
    out <- list()
    for (n in nodes) {
        # find function_declarator -> identifier
        fd <- find_child_of_type(n, "function_declarator")
        if (is.null(fd)) {
            # declaration might contain function_declarator deeper
            # search children
            fd <- NULL
            nc <- treesitter::node_child_count(n)
            for (i in seq_len(nc)) {
                ch <- treesitter::node_child(n, i)
                if (treesitter::node_type(ch) == "function_declarator") {
                    fd <- ch
                    break
                }
            }
        }
        if (!is.null(fd)) {
            id <- find_child_of_type(fd, "identifier")
            if (!is.null(id)) {
                text <- treesitter::node_text(id)
                sp <- treesitter::node_start_point(id)
                if (is.null(sp)) {
                    sl <- NA_integer_
                } else if (is.numeric(sp) && length(sp) >= 2) {
                    sl <- as.integer(sp[1] + 1L)
                } else if (is.list(sp) && ("row" %in% names(sp))) {
                    sl <- as.integer(sp$row + 1L)
                } else {
                    sl <- NA_integer_
                }
                cname <- if (treesitter::node_type(n) == "function_definition") {
                    "def_name"
                } else {
                    "decl_name"
                }
                if (is.null(sp)) {
                    scol <- NA_integer_
                } else if (is.numeric(sp) && length(sp) >= 2) {
                    scol <- as.integer(sp[2] + 1L)
                } else if (is.list(sp) && ("column" %in% names(sp))) {
                    scol <- as.integer(sp$column + 1L)
                } else {
                    scol <- NA_integer_
                }
                entry <- list(
                    capture_name = cname,
                    text = text,
                    start_line = sl,
                    start_col = scol
                )
                if (isTRUE(extract_params)) {
                    # find parameter_declaration nodes within fd (function_declarator)
                    # use declared function_declarator (fd) to find parameter_declaration
                    pnodes <- find_descendants_by_type(fd, c("parameter_declaration"))
                    # Extract types from parameter_declaration nodes by searching descendant type nodes
                    params <- c()
                    if (length(pnodes) > 0) {
                        # Use node structure rather than regex: collect node_text from children
                        # while skipping identifier/field_identifier nodes.
                        get_param_type <- function(node) {
                            # Recursive traversal that excludes identifier nodes
                            rec <- function(nd) {
                                if (is.null(nd)) {
                                    return(character(0))
                                }
                                t <- treesitter::node_type(nd)
                                if (t %in% c("identifier", "field_identifier")) {
                                    return(character(0))
                                }
                                # If leaf, return node text
                                if (treesitter::node_child_count(nd) == 0) {
                                    return(treesitter::node_text(nd))
                                }
                                out <- character(0)
                                nc <- treesitter::node_child_count(nd)
                                if (nc > 0) {
                                    for (i in seq_len(nc)) {
                                        ch <- treesitter::node_child(nd, i)
                                        v <- rec(ch)
                                        if (length(v) > 0 && nzchar(v)) out <- c(out, v)
                                    }
                                }
                                if (length(out) == 0) {
                                    return(character(0))
                                }
                                paste(out, collapse = " ")
                            }
                            trimws(rec(node))
                        }
                        for (pn in pnodes) {
                            ptype <- get_param_type(pn)
                            params <- c(params, if (nzchar(ptype)) ptype else NA_character_)
                        }
                    }
                    entry$params <- if (length(params) > 0) params else character(0)
                }
                if (isTRUE(extract_return)) {
                    # attempt to find the return type: prefer direct children (primitive_type or type_identifier)
                    get_return_type <- function(node) {
                        nc <- treesitter::node_child_count(node)
                        for (ci in seq_len(nc)) {
                            ch <- treesitter::node_child(node, ci)
                            if (treesitter::node_type(ch) %in% c("primitive_type", "type_identifier")) {
                                return(treesitter::node_text(ch))
                            }
                        }
                        # fallback: find descendant types that are not inside the function_declarator
                        candidates <- find_descendants_by_type(node, c("primitive_type", "type_identifier"))
                        if (length(candidates) == 0) {
                            return(NA_character_)
                        }
                        for (cand in candidates) {
                            # walk up parents to see if any parent is a function_declarator - skip those
                            parent <- treesitter::node_parent(cand)
                            inside_fd <- FALSE
                            while (!is.null(parent) && !identical(parent, node)) {
                                if (treesitter::node_type(parent) == "function_declarator") {
                                    inside_fd <- TRUE
                                    break
                                }
                                parent <- treesitter::node_parent(parent)
                            }
                            if (!inside_fd) {
                                return(treesitter::node_text(cand))
                            }
                        }
                        NA_character_
                    }
                    entry$return_type <- get_return_type(n)
                }
                out[[length(out) + 1L]] <- entry
            }
        }
    }
    if (length(out) == 0L) {
        return(data.frame(
            capture_name = character(0),
            text = character(0),
            start_line = integer(0),
            start_col = integer(0),
            params = I(list()),
            stringsAsFactors = FALSE
        ))
    }
    # Include params list-column if present
    df <- do.call(
        rbind,
        lapply(out, function(x) {
            params_col <- I(list(character(0)))
            if (!is.null(x$params)) params_col <- I(list(x$params))
            data.frame(
                capture_name = x$capture_name,
                text = x$text,
                start_line = x$start_line,
                start_col = x$start_col,
                params = params_col,
                return_type = if (!is.null(x$return_type)) x$return_type else NA_character_,
                stringsAsFactors = FALSE
            )
        })
    )
    df
}

#' Extract struct names from a parsed tree root
#'
#' @param root A tree-sitter root node from `parse_header_text()`.
#' @return Data frame with struct name captures.
#' @export
get_struct_nodes <- function(root) {
    nodes <- find_nodes_by_type(root, c("struct_specifier"))
    out <- list()
    for (n in nodes) {
        id <- find_child_of_type(n, "type_identifier")
        if (!is.null(id)) {
            text <- treesitter::node_text(id)
            sp <- treesitter::node_start_point(id)
            if (is.null(sp)) {
                sl <- NA_integer_
            } else if (is.numeric(sp) && length(sp) >= 2) {
                sl <- as.integer(sp[1] + 1L)
            } else if (is.list(sp) && ("row" %in% names(sp))) {
                sl <- as.integer(sp$row + 1L)
            } else {
                sl <- NA_integer_
            }
            out[[length(out) + 1L]] <- list(
                capture_name = "struct_name",
                text = text,
                start_line = sl
            )
        }
    }
    if (length(out) == 0L) {
        return(data.frame(
            capture_name = character(0),
            text = character(0),
            start_line = integer(0),
            stringsAsFactors = FALSE
        ))
    }
    do.call(
        rbind,
        lapply(out, function(x) {
            data.frame(
                capture_name = x$capture_name,
                text = x$text,
                start_line = x$start_line,
                stringsAsFactors = FALSE
            )
        })
    )
}

#' Extract members of structs (including nested anonymous struct members)
#'
#' @param root A tree-sitter root node.
#' @return Data frame describing struct members, including bitfields.
#' @export
get_struct_members <- function(root) {
    nodes <- find_nodes_by_type(root, c("struct_specifier"))
    out <- list()
    for (n in nodes) {
        struct_id <- find_child_of_type(n, "type_identifier")
        struct_name <- if (!is.null(struct_id)) {
            treesitter::node_text(struct_id)
        } else {
            NA_character_
        }
        # find field_declaration_list inside struct body
        fields <- find_descendants_by_type(n, c("field_declaration"))
        for (f in fields) {
            # type may be primitive_type or type_identifier or specifier
            tnode <- find_child_of_type(f, "primitive_type")
            if (is.null(tnode)) {
                tnode <- find_child_of_type(f, "type_identifier")
            }
            mtype <- if (!is.null(tnode)) {
                treesitter::node_text(tnode)
            } else {
                NA_character_
            }
            member_type <- mtype
            # find identifier in declarator (direct child, not nested)
            decl <- find_child_of_type(f, "field_identifier")
            if (is.null(decl)) {
                decl <- find_child_of_type(f, "identifier")
            }
            name <- if (!is.null(decl)) treesitter::node_text(decl) else NA_character_
            # detect bitfield: find bitfield_clause under f
            bf <- find_descendants_by_type(f, c("bitfield_clause"))
            if (length(bf) >= 1) {
                bfexpr <- treesitter::node_text(bf[[1]])
                bfval <- sub("^\\s*:\\s*", "", bfexpr)
            } else {
                bfval <- NA_character_
            }
            # detect if field contains anonymous struct: check for struct_specifier child
            ss <- find_descendants_by_type(f, c("struct_specifier"))
            nested_members <- NA_character_
            if (length(ss) >= 1) {
                # determine if the struct_specifier is anonymous (no type_identifier child)
                si <- ss[[1]]
                type_id <- find_child_of_type(si, "type_identifier")
                if (is.null(type_id)) {
                    member_type <- "struct (anonymous)"
                    # extract nested fields of anonymous struct
                    nested_fields <- find_descendants_by_type(si, c("field_declaration"))
                    nm <- c()
                    for (nf in nested_fields) {
                        fid <- find_descendants_by_type(
                            nf,
                            c("field_identifier", "identifier")
                        )
                        fn <- if (length(fid) >= 1) {
                            treesitter::node_text(fid[[1]])
                        } else {
                            NA_character_
                        }
                        bfn <- find_descendants_by_type(nf, c("bitfield_clause"))
                        bfv <- if (length(bfn) >= 1) {
                            sub("^\\s*:\\s*", "", treesitter::node_text(bfn[[1]]))
                        } else {
                            NA_character_
                        }
                        nm <- c(nm, if (!is.na(bfv)) paste0(fn, ":", bfv) else fn)
                    }
                    if (length(nm) > 0) nested_members <- paste(nm, collapse = ",")
                } else {
                    member_type <- "struct"
                }
            }
            out[[length(out) + 1]] <- list(
                struct_name = struct_name,
                member_name = name,
                member_type = if (!is.null(member_type)) member_type else mtype,
                bitfield = bfval,
                nested_members = if (!is.null(nested_members)) {
                    nested_members
                } else {
                    NA_character_
                }
            )
        }
    }
    if (length(out) == 0) {
        return(data.frame(
            struct_name = character(0),
            member_name = character(0),
            member_type = character(0),
            bitfield = character(0),
            nested_members = character(0),
            stringsAsFactors = FALSE
        ))
    }
    do.call(
        rbind,
        lapply(out, function(x) {
            data.frame(
                struct_name = x$struct_name,
                member_name = x$member_name,
                member_type = x$member_type,
                bitfield = x$bitfield,
                nested_members = if (!is.null(x$nested_members)) {
                    x$nested_members
                } else {
                    NA_character_
                },
                stringsAsFactors = FALSE
            )
        })
    )
}

#' Extract enum names from a parsed header
#'
#' @param root A tree-sitter root node.
#' @return Data frame with enum names.
#' @export
get_enum_nodes <- function(root) {
    nodes <- find_nodes_by_type(root, c("enum_specifier"))
    out <- list()
    for (n in nodes) {
        id <- find_child_of_type(n, "type_identifier")
        if (!is.null(id)) {
            text <- treesitter::node_text(id)
            sp <- treesitter::node_start_point(id)
            if (is.null(sp)) {
                sl <- NA_integer_
            } else if (is.numeric(sp) && length(sp) >= 2) {
                sl <- as.integer(sp[1] + 1L)
            } else if (is.list(sp) && ("row" %in% names(sp))) {
                sl <- as.integer(sp$row + 1L)
            } else {
                sl <- NA_integer_
            }
            out[[length(out) + 1L]] <- list(
                capture_name = "enum_name",
                text = text,
                start_line = sl
            )
        }
    }
    if (length(out) == 0L) {
        return(data.frame(
            capture_name = character(0),
            text = character(0),
            start_line = integer(0),
            stringsAsFactors = FALSE
        ))
    }
    do.call(
        rbind,
        lapply(out, function(x) {
            data.frame(
                capture_name = x$capture_name,
                text = x$text,
                start_line = x$start_line,
                stringsAsFactors = FALSE
            )
        })
    )
}

#' Extract union names from a parsed header
#'
#' @param root A tree-sitter root node.
#' @return Data frame with union names.
#' @export
get_union_nodes <- function(root) {
    nodes <- find_nodes_by_type(root, c("union_specifier"))
    out <- list()
    for (n in nodes) {
        id <- find_child_of_type(n, "type_identifier")
        if (!is.null(id)) {
            text <- treesitter::node_text(id)
            sp <- treesitter::node_start_point(id)
            if (is.null(sp)) {
                sl <- NA_integer_
            } else if (is.numeric(sp) && length(sp) >= 2) {
                sl <- as.integer(sp[1] + 1L)
            } else if (is.list(sp) && ("row" %in% names(sp))) {
                sl <- as.integer(sp$row + 1L)
            } else {
                sl <- NA_integer_
            }
            out[[length(out) + 1L]] <- list(
                capture_name = "union_name",
                text = text,
                start_line = sl
            )
        }
    }
    if (length(out) == 0L) {
        return(data.frame(
            capture_name = character(0),
            text = character(0),
            start_line = integer(0),
            stringsAsFactors = FALSE
        ))
    }
    do.call(
        rbind,
        lapply(out, function(x) {
            data.frame(
                capture_name = x$capture_name,
                text = x$text,
                start_line = x$start_line,
                stringsAsFactors = FALSE
            )
        })
    )
}

#' Extract global variable names from a parsed tree root
#'
#' @param root A tree-sitter root node.
#' @return Data frame with top-level global names.
#' @export
get_globals_from_root <- function(root) {
    # declarations at the top-level: parent is translation_unit
    q <- treesitter::query(
        language(),
        "(declaration declarator: (init_declarator declarator: (identifier) @global_name))"
    )
    nodes <- find_nodes_by_type(root, c("declaration"))
    out <- list()
    for (n in nodes) {
        id <- find_child_of_type(n, "init_declarator")
        if (!is.null(id)) {
            id2 <- find_child_of_type(id, "identifier")
            if (!is.null(id2)) {
                text <- treesitter::node_text(id2)
                sp <- treesitter::node_start_point(id2)
                if (is.null(sp)) {
                    sl <- NA_integer_
                } else if (is.numeric(sp) && length(sp) >= 2) {
                    sl <- as.integer(sp[1] + 1L)
                } else if (is.list(sp) && ("row" %in% names(sp))) {
                    sl <- as.integer(sp$row + 1L)
                } else {
                    sl <- NA_integer_
                }
                out[[length(out) + 1L]] <- list(
                    capture_name = "global_name",
                    text = text,
                    start_line = sl
                )
            }
        }
    }
    if (length(out) == 0L) {
        return(data.frame(
            capture_name = character(0),
            text = character(0),
            start_line = integer(0),
            stringsAsFactors = FALSE
        ))
    }
    do.call(
        rbind,
        lapply(out, function(x) {
            data.frame(
                capture_name = x$capture_name,
                text = x$text,
                start_line = x$start_line,
                stringsAsFactors = FALSE
            )
        })
    )
}

#+ Get macro names from a header file using either the preprocessor or a naive scan
#'
#' This function will use the configured C compiler to list macro definitions (`-dM -E`) if
#' `use_cpp = TRUE` and a compiler is available; otherwise, a simple scan of `#define` lines
#' is used as a fallback.
#'
#' @param file Path to a header file
#' @param use_cpp Logical; use the C preprocessor if available
#' @param cc Compiler string; passed to `system2` if `use_cpp = TRUE`.
#' @param ccflags Additional flags for the compiler
#' @return Character vector of macro names defined in `file`
#' @export
get_defines_from_file <- function(
  file,
  use_cpp = TRUE,
  cc = r_cc(),
  ccflags = NULL
) {
    if (!file.exists(file)) {
        stop("file does not exist: ", file)
    }

    if (use_cpp) {
        # Use the preprocessor to list macros. `-dM -E` prints all macro definitions.
        cc_raw <- cc
        cc_parts <- if (nzchar(cc_raw)) {
            unlist(strsplit(cc_raw, "\\s+"))
        } else {
            character(0)
        }
        cc_prog <- if (length(cc_parts) >= 1) cc_parts[1] else ""
        cc_prog_args <- if (length(cc_parts) >= 2) cc_parts[-1] else character(0)
        if (!nzchar(cc_prog)) {
            # fallback to regex parse if no compiler available
            warning(
                "No C compiler configured; falling back to header scan for defines"
            )
            use_cpp <- FALSE
        }
    }

    if (use_cpp) {
        if (is.null(ccflags) || !nzchar(ccflags)) {
            ccflags <- r_ccflags()
        }
        flags <- if (nzchar(ccflags)) {
            unlist(strsplit(ccflags, "\\s+"))
        } else {
            character(0)
        }
        args <- c(cc_prog_args, flags, "-dM", "-E", file)
        out <- tryCatch(
            suppressWarnings(system2(cc_prog, args, stdout = TRUE, stderr = TRUE)),
            error = function(e) NULL
        )
        if (is.null(out)) {
            warning("Preprocessor failed; falling back to header scan for defines")
            use_cpp <- FALSE
        } else {
            # parse lines like '#define NAME value' and extract NAME
            res <- regmatches(
                out,
                regexec("^\\s*#\\s*define\\s+([A-Za-z_][A-Za-z0-9_]*)", out)
            )
            names <- vapply(
                res,
                function(x) if (length(x) >= 2) x[2] else NA_character_,
                ""
            )
            names <- names[!is.na(names) & nzchar(names)]
            return(unique(names))
        }
    }

    # Fallback: naive scan of header file lines for '#define' directives
    lines <- readLines(file, warn = FALSE)
    m <- regexec("^\\s*#\\s*define\\s+([A-Za-z_][A-Za-z0-9_]*)", lines)
    res <- regmatches(lines, m)
    vals <- vapply(
        res,
        function(x) if (length(x) >= 2) x[2] else NA_character_,
        ""
    )
    names <- gsub("^.*define\\s+", "", vals)
    names <- names[!is.na(names) & nzchar(names)]
    unique(names)
}

#' Parse C header files for function declarations using tree-sitter
#'
#' This utility uses the C language provided by this package and the
#' treesitter parser to find function declarations and definitions in
#' C header files. The default `dir` is `R.home("include")`, which is
#' typically where R's headers live.
#'
#' @param dir Directory to search for header files. Defaults to
#'   `R.home("include")`.
#' @param recursive Whether to search recursively for headers. Default
#'   `TRUE`.
#' @param pattern File name pattern to match header files. Default is
#'   `\.h$` and `\.H$`.
#' @param preprocess Run the C preprocessor (using R's configured CC) on
#'   header files before parsing. Defaults to `FALSE`.
#' @param cc The C compiler to use for preprocessing. If `NULL` the
#'   function queries `R CMD config CC` and falls back to `Sys.getenv("CC")`
#'   and the `cc` on PATH.
#' @param ccflags Extra flags to pass to the compiler when preprocessing.
#'   If `NULL` flags are taken from `R CMD config CFLAGS` and `R CMD config CPPFLAGS`.
#' @param include_dirs Additional directories to add to the include path for preprocessing. A character vector of directories.
#' @return A data frame with columns `name`, `file`, `line`, and `kind`
#'   (either 'declaration' or 'definition').
#' @examples
#' if (requireNamespace("treesitter", quietly = TRUE)) {
#'     # Parse a small header file from a temp dir
#'     tmp <- tempdir()
#'     path <- file.path(tmp, "example.h")
#'     writeLines(c(
#'         "int foo(int a);",
#'         "static inline int bar(void) { return 1; }"
#'     ), path)
#'     parse_r_include_headers(dir = tmp)
#' }
#' @export
parse_r_include_headers <- function(
  dir = R.home("include"),
  recursive = TRUE,
  pattern = c("\\.h$", "\\.H$"),
  preprocess = FALSE,
  cc = r_cc(),
  ccflags = NULL,
  include_dirs = NULL
) {
    if (!requireNamespace("treesitter", quietly = TRUE)) {
        stop(
            "`treesitter` package is required to parse headers. Please install it."
        )
    }
    if (!dir.exists(dir)) {
        stop("Directory does not exist: ", dir)
    }
    files <- list.files(
        dir,
        pattern = paste0("(", paste(pattern, collapse = "|"), ")"),
        full.names = TRUE,
        recursive = recursive
    )
    if (length(files) == 0L) {
        return(data.frame(
            name = character(0),
            file = character(0),
            line = integer(0),
            kind = character(0),
            stringsAsFactors = FALSE
        ))
    }
    out <- list()
    for (f in files) {
        flags <- if (is.null(ccflags) || !nzchar(ccflags)) r_ccflags() else ccflags
        content <- if (preprocess) {
            # Add include dirs: ensure the header dir itself is in ccflags and append any
            # user-provided include_dirs.
            extra <- character(0)
            # always add the directory of the file being preprocessed
            extra <- c(extra, paste0("-I", dirname(f)))
            if (!is.null(include_dirs)) {
                extra <- c(extra, paste0("-I", include_dirs))
            }
            preprocess_header(f, cc = cc, ccflags = paste(flags, paste(extra, collapse = " ")))
        } else {
            paste(readLines(f, warn = FALSE), collapse = "\n")
        }
        root <- parse_header_text(content)
        funcs <- tryCatch(get_function_nodes(root), error = function(e) NULL)
        if (!is.null(funcs) && is.data.frame(funcs) && nrow(funcs) > 0) {
            for (i in seq_len(nrow(funcs))) {
                cn <- funcs$capture_name[i]
                name <- funcs$text[i]
                line <- funcs$start_line[i]
                kind <- if (cn == "def_name") {
                    "definition"
                } else if (cn == "decl_name") {
                    "declaration"
                } else {
                    "unknown"
                }
                out[[length(out) + 1L]] <- list(
                    name = name,
                    file = f,
                    line = line,
                    kind = kind
                )
            }
        }
    }
    if (length(out) == 0L) {
        return(data.frame(
            name = character(0),
            file = character(0),
            line = integer(0),
            kind = character(0),
            stringsAsFactors = FALSE
        ))
    }
    res <- do.call(
        rbind,
        lapply(out, function(x) {
            data.frame(
                name = x$name,
                file = x$file,
                line = x$line,
                kind = x$kind,
                stringsAsFactors = FALSE
            )
        })
    )
    res <- unique(res)
    rownames(res) <- NULL
    res
}


#+ Convenience: parse headers directory and return many kinds of results
#+
#' Parse a directory of headers and return named list of data.frames with
#' functions, structs, struct members, enums, unions, globals, and macros.
#'
#' This helper loops over headers found in a directory and returns a list
#' with tidy data.frames. Useful for programmatic analysis of header
#' collections.
#'
#' @param dir Directory to search for header files. Defaults to `R.home("include")`.
#' @param recursive Whether to search recursively for headers. Default `TRUE`.
#' @param pattern File name pattern to match header files. Default is `\.h$` and `\.H$`.
#' @param preprocess Run the C preprocessor (using R's configured CC) on header files before parsing. Defaults to `FALSE`.
#' @param cc The C compiler to use for preprocessing. If `NULL` the function queries `R CMD config CC` and falls back to `Sys.getenv("CC")` and the `cc` on PATH.
#' @param ccflags Extra flags to pass to the compiler when preprocessing. If `NULL` flags are taken from `R CMD config CFLAGS` and `R CMD config CPPFLAGS`.
#' @param include_dirs Additional directories to add to the include path for preprocessing. A character vector of directories.
#' @param extract_params Logical; whether to extract parameter types for functions. Default `FALSE`.
#' @return A named list of data frames with components: `functions`, `structs`, `struct_members`, `enums`, `unions`, `globals`, `defines`.
#' @examples
#' \dontrun{
#' if (requireNamespace("treesitter", quietly = TRUE)) {
#'     res <- parse_headers_collect(dir = R.home("include"), preprocess = FALSE)
#'     head(res$functions)
#' }
#' }
#' @export
parse_headers_collect <- function(
  dir = R.home("include"),
  recursive = TRUE,
  pattern = c("\\.h$", "\\.H$"),
  preprocess = FALSE,
  cc = r_cc(),
  ccflags = NULL,
  include_dirs = NULL,
  extract_params = FALSE,
  extract_return = FALSE
) {
    if (!requireNamespace("treesitter", quietly = TRUE)) stop("treesitter required")
    if (!dir.exists(dir)) stop("Directory does not exist: ", dir)
    files <- list.files(dir, pattern = paste0("(", paste(pattern, collapse = "|"), ")"), full.names = TRUE, recursive = recursive)
    if (length(files) == 0L) {
        out <- list(
            functions = data.frame(name = character(0), file = character(0), line = integer(0), kind = character(0), params = I(list())),
            structs = data.frame(capture_name = character(0), text = character(0), start_line = integer(0)),
            struct_members = data.frame(struct_name = character(0), member_name = character(0), member_type = character(0), bitfield = character(0), nested_members = character(0)),
            enums = data.frame(capture_name = character(0), text = character(0), start_line = integer(0)),
            unions = data.frame(capture_name = character(0), text = character(0), start_line = integer(0)),
            globals = data.frame(capture_name = character(0), text = character(0), start_line = integer(0)),
            defines = character(0)
        )
        return(out)
    }
    agg <- list(functions = list(), structs = list(), struct_members = list(), enums = list(), unions = list(), globals = list(), defines = character(0))
    for (f in files) {
        flags <- if (is.null(ccflags) || !nzchar(ccflags)) r_ccflags() else ccflags
        content <- if (preprocess) {
            extra <- c(paste0("-I", dirname(f)))
            if (!is.null(include_dirs)) extra <- c(extra, paste0("-I", include_dirs))
            preprocess_header(f, cc = cc, ccflags = paste(ccflags, paste(extra, collapse = " ")))
        } else {
            paste(readLines(f, warn = FALSE), collapse = "\n")
        }
        root <- tryCatch(parse_header_text(content), error = function(e) NULL)
        if (is.null(root)) next
        funcs <- tryCatch(get_function_nodes(root, extract_params = extract_params, extract_return = extract_return), error = function(e) NULL)
        if (!is.null(funcs) && nrow(funcs) > 0) {
            func_df <- data.frame(file = f, funcs, stringsAsFactors = FALSE)
            # Rename 'text' column from get_function_nodes to 'name' for convenience
            if ("text" %in% colnames(func_df)) {
                func_df$name <- func_df$text
                func_df$text <- NULL
            }
            agg$functions[[length(agg$functions) + 1]] <- func_df
        }
        structs <- tryCatch(get_struct_nodes(root), error = function(e) NULL)
        if (!is.null(structs) && nrow(structs) > 0) {
            agg$structs[[length(agg$structs) + 1]] <- cbind(file = f, structs)
        }
        members <- tryCatch(get_struct_members(root), error = function(e) NULL)
        if (!is.null(members) && nrow(members) > 0) {
            agg$struct_members[[length(agg$struct_members) + 1]] <- cbind(file = f, members)
        }
        enums <- tryCatch(get_enum_nodes(root), error = function(e) NULL)
        if (!is.null(enums) && nrow(enums) > 0) {
            agg$enums[[length(agg$enums) + 1]] <- cbind(file = f, enums)
        }
        unions <- tryCatch(get_union_nodes(root), error = function(e) NULL)
        if (!is.null(unions) && nrow(unions) > 0) {
            agg$unions[[length(agg$unions) + 1]] <- cbind(file = f, unions)
        }
        globals <- tryCatch(get_globals_from_root(root), error = function(e) NULL)
        if (!is.null(globals) && nrow(globals) > 0) {
            agg$globals[[length(agg$globals) + 1]] <- cbind(file = f, globals)
        }
        defs <- tryCatch(get_defines_from_file(f, use_cpp = preprocess, cc = cc, ccflags = ccflags), error = function(e) character(0))
        if (length(defs) > 0) agg$defines <- unique(c(agg$defines, defs))
    }
    out_list <- list(
        functions = if (length(agg$functions) > 0) do.call(rbind, agg$functions) else data.frame(name = character(0), file = character(0), line = integer(0), kind = character(0), params = I(list())),
        structs = if (length(agg$structs) > 0) do.call(rbind, agg$structs) else data.frame(capture_name = character(0), text = character(0), start_line = integer(0)),
        struct_members = if (length(agg$struct_members) > 0) do.call(rbind, agg$struct_members) else data.frame(struct_name = character(0), member_name = character(0), member_type = character(0), bitfield = character(0), nested_members = character(0)),
        enums = if (length(agg$enums) > 0) do.call(rbind, agg$enums) else data.frame(capture_name = character(0), text = character(0), start_line = integer(0)),
        unions = if (length(agg$unions) > 0) do.call(rbind, agg$unions) else data.frame(capture_name = character(0), text = character(0), start_line = integer(0)),
        globals = if (length(agg$globals) > 0) do.call(rbind, agg$globals) else data.frame(capture_name = character(0), text = character(0), start_line = integer(0)),
        defines = agg$defines
    )
    out_list
}
