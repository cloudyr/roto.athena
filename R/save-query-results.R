#' Save Query Results to Disk
#'
#' Downloadsthe results of a single query execution specified by
#' `query_execution_id` to `filename`. This request does not execute
#' the query but returns results. Use [start_query_execution()] to run a query.
#'
#' This is useful for downloading large results where it is undesireable
#' to load the full dataset into memory.
#'
#' @md
#' @param query_execution_id unique ID of the query execution.
#' @param filename download location of the athena result
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @return the filename
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
#' save_query_results(sqe, filename)
#' }
save_query_results <- function(query_execution_id,
                               filename,
                              aws_access_key_id = NULL,
                              aws_secret_access_key = NULL,
                              aws_session_token = NULL,
                              region_name = NULL,
                              profile_name = NULL) {

  boto3$session$Session(
    aws_access_key_id = aws_access_key_id,
    aws_secret_access_key = aws_secret_access_key,
    aws_session_token = aws_session_token,
    region_name = region_name,
    profile_name = profile_name
  ) -> session

  client <- session$client("athena")
  res   <- client$get_query_execution(
    QueryExecutionId = query_execution_id)
  #print(res)

  # obtain the S3 output path and download directly
  s3     <- session$client("s3")
  s3path <- res$QueryExecution$ResultConfiguration$OutputLocation
  s3path <- gsub("s3://", "", s3path)
  bucket <- strsplit(s3path, "/")[[1]][[1]]
  s3key  <- paste(
                strsplit(s3path, "/")[[1]][-1],
                collapse = "/")

  # check to see if the oject exists
  try(s3obj <- s3$head_object(Bucket=bucket, Key=s3key))

  if (exists("s3obj")) {
    print(paste("downloading athena results file", s3path))
    s3$download_file(Bucket = bucket, Key = s3key , Filename = filename)
  }

  filename
}

