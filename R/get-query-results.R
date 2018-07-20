#' Get Query Results
#'
#' Returns the results of a single query execution specified by
#' `query_execution_id`. This request does not execute the query but returns
#' results. Use [start_query_execution()] to run a query.
#'
#' While this function works, it may be faster to use the `awscli` utility
#' to sync the cached CSV file and use your favorite R CSV reader. One
#' advantage of this function is that it does know the column types (and
#' sets them appropriately) but you also know what the column types are
#' since you are querying a database you have access to. You should consider
#' performing some real-world performance tests and choose the result set
#' ingestion method that works best for you.
#'
#' @md
#' @param query_execution_id unique ID of the query execution.
#' @param chunk_size the AWS Athena API returns the result set in batches. Smaller
#'        values for `chunk_size` mean more requests are made to retrieve the
#'        entire result set. Larger values for `chunk_size` will retrieve more
#'        data for each call but may not be as performant depending on many
#'        factors including network speed, AWS region, etc. Tune this if the
#'        default causes API failures for your situation. The maximum value
#'        (set by the AWS Athena API endpoint) is 1000.
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @return data frame (tibble)
#' @note This retrieves _all_ the results (i.e. it handles pagination for you).
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.get_query_results>
#' @export
#' @examples \dontrun{
#' start_query_execution(
#'   query = "SELECT * FROM elb_logs LIMIT 100",
#'   database = "sampledb",
#'   output_location = "s3://aws-athena-query-results-redacted",
#'   profile = "personal"
#' ) -> sqe
#'
#' # wait a bit
#'
#' get_query_results(sqe)
#' }
get_query_results <- function(query_execution_id,
                              chunk_size = 1000L,
                              aws_access_key_id = NULL,
                              aws_secret_access_key = NULL,
                              aws_session_token = NULL,
                              region_name = NULL,
                              profile_name = NULL) {

  if (chunk_size > 1000) {
    message("Adjusting chunk size to 1000...")
    chunk_size <- 1000L
  }

  boto3$session$Session(
    aws_access_key_id = aws_access_key_id,
    aws_secret_access_key = aws_secret_access_key,
    aws_session_token = aws_session_token,
    region_name = region_name,
    profile_name = profile_name
  ) -> session

  client <- session$client("athena")

  res <- .get_query_results(client, query_execution_id, NULL, as.integer(chunk_size))

  col_names <- unlist(res[[1]]$ResultSet$Rows[[1]], use.names = FALSE)

  lapply(1:length(res), function(.x) {

    rows <- res[[.x]]$ResultSet$Rows

    start <- if (.x == 1) 2 else 1

    lapply(rows[start:length(rows)], function(.y) {
      dat <- as.list(unlist(.y$Data, use.names = FALSE))
      if (length(dat) > 0) dat <- stats::setNames(dat, col_names)
      as.data.frame(dat, stringsAsFactors = FALSE)
    }) -> out

    do.call(rbind.data.frame, out)

  }) -> out
  out <- do.call(rbind.data.frame, out)
  class(out) <- c("tbl_df", "tbl", "data.frame")

  out

  col_info <- res[[1]]$ResultSet$ResultSetMetadata$ColumnInfo

  for (i in 1:length(col_info)) {
    col_name <- col_info[[i]]$Name
    col_type <- col_info[[i]]$Type
    if (col_type == "integer") {
      out[,col_name] <- as.integer(out[[col_name]])
    } else if (col_type == "double") {
      out[,col_name] <- as.double(out[[col_name]])
    } else if (col_type == "bigint") {
      out[,col_name] <- bit64::as.integer64(out[[col_name]])
    }
  }

  out

}

