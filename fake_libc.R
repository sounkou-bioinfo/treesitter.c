#' Download and install pycparser's fake_libc_include headers
#'
#' This script downloads the pycparser release, extracts the fake_libc_include directory,
#' and copies its contents to inst/fake_libc. It also adds copyright info for Eli Bendersky and Co-authors.
#'
#' Usage: source('fake_libc.R')

url <- "https://github.com/eliben/pycparser/archive/refs/tags/release_v2.23.tar.gz"
tmpfile <- tempfile("pycparser", fileext = ".tar.gz")
tmpdir <- tempfile("pycparser_dir")
dir.create(tmpdir)

message("Downloading pycparser...\n")
download.file(url, tmpfile, mode = "wb")
message("Extracting archive...\n")
untar(tmpfile, exdir = tmpdir)

src_dir <- file.path(
  tmpdir,
  "pycparser-release_v2.23",
  "utils",
  "fake_libc_include"
)
dest_dir <- file.path("inst", "fake_libc")
if (!dir.exists(dest_dir)) {
  dir.create(dest_dir, recursive = TRUE)
}

message("Copying fake_libc_include files...\n")
files <- list.files(src_dir, full.names = TRUE)
file.copy(files, dest_dir, overwrite = TRUE, recursive = TRUE)


message("Done. Files installed to inst/fake_libc\n")
