# Bootstrap: fetch pre-generated tree-sitter-c parser

grammar_dir <- "tree-sitter-c"

if (!dir.exists(grammar_dir)) {
  system2(
    "git",
    c(
      "clone",
      "--depth",
      "1",
      "https://github.com/tree-sitter/tree-sitter-c",
      grammar_dir
    )
  )
}

old_dir <- setwd(grammar_dir)
system2("git", c("fetch", "--depth", "50"), stdout = FALSE, stderr = FALSE)
system2("git", c("checkout", "e6fb5bc"), stdout = FALSE, stderr = FALSE)
setwd(old_dir)

if (!dir.exists("src")) {
  dir.create("src")
}
if (!dir.exists("src/tree_sitter")) {
  dir.create("src/tree_sitter")
}

file.copy(
  file.path(grammar_dir, "src", "parser.c"),
  "src/parser.c",
  overwrite = TRUE
)
file.copy(
  file.path(grammar_dir, "src", "tree_sitter", "parser.h"),
  "src/tree_sitter/parser.h",
  overwrite = TRUE
)

# Remove pragmas in src/parser.c for CRAN compliance
if (file.exists("src/parser.c")) {
  lines <- readLines("src/parser.c")
  # Remove all pragma lines completely
  lines <- lines[!grepl("^\\s*#\\s*pragma", lines)]
  writeLines(lines, "src/parser.c")
}

unlink(grammar_dir, recursive = TRUE)

if (file.exists("src/parser.c") && file.exists("src/tree_sitter/parser.h")) {
  message("Bootstrap complete")
} else {
  stop("Bootstrap failed")
}
