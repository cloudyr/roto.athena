x <- reticulate::py_config()

if (utils::compareVersion(x$version, "3.5") < 0) {
  stop(
    paste0(
      c(
        "Python 3.5+ is required. If this is installed please set RETICULATE_PYTHON ",
        "to the path to the Python 3 binary on your system and try re-installing/",
        "re-loading the package."
      ),
      collapse = ""
    )
  )
}

boto3 <- NULL
os <- NULL

.onLoad <- function(libname, pkgname) {
  os <<- reticulate::import("os", delay_load = TRUE)
  if (!reticulate::py_module_available("boto3")) {
    stop("The 'boto3' Python module must be installed.", call.=FALSE)
  }
  boto3 <<- reticulate::import("boto3", delay_load = TRUE)
}