#' Perform and Manage 'Amazon' 'Athena' Queries
#'
#' This is a 'reticulated' wrapper for the 'Python' 'boto3' 'AWS' 'Athena'
#' client library <https://boto3.readthedocs.io/en/latest/reference/services/athena.html>.
#' It requires 'Python' version 3.5+ and an 'AWS' account. Tools are also provided
#' to execute 'dplyr' chains asynchronously.
#'
#' @md
#' @name roto.athena
#' @note This package **requires** Python >= 3.5 to be available and the
#'       `boto3` Python module. The package author highly recommends setting
#'       `RETICULATE_PYTHON=/usr/local/bin/python3` in your `~/.Renviron` file
#'       to ensure R + `reticulate` will use the proper python version.
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import reticulate bit64
#' @importFrom stats setNames
NULL
