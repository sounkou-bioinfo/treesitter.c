#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

// Forward declarations
SEXP ffi_language(void);

// Symbol registration
static const R_CallMethodDef CallEntries[] = {
  {"ffi_language", (DL_FUNC) &ffi_language, 0},
  {NULL, NULL, 0}
};

void R_init_treesitter_c(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
