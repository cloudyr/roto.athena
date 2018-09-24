#' Execute a Query and Save it to disk
#'
#' This funciton combines the `start_query_execution` with the
#' `save_query_results` function to execute, run, and retrieve
#' the results of a SQL query on Athena.
#'
#' This is useful for downloading large results where it is undesireable
#' to load the full dataset into memory.
#'
#' @md
#' @param query SQL query statements to be executed
#' @param database database within which the query executes.
#' @param output_location location in S3 where query results are stored.
#' @param local_filename download location of the athena result
#' @param client_request_token unique case-sensitive string used to ensure the
#'        request to create the query is idempotent (executes only once). If another
#'        `StartQueryExecution` request is received, the same response is returned
#'        and another query is not created. If a parameter has changed, for example,
#'        the `query` , an error is returned. **This is auto-generated-for-you**.
#' @param encryption_option indicates whether Amazon S3 server-side encryption
#'        with Amazon S3-managed keys (`SSE-S3`), server-side encryption with
#'        KMS-managed keys (`SSE-KMS`), or client-side encryption with KMS-managed
#'        keys (`CSE-KMS`) is used. Default is `NULL` (no encryption)
#' @param kms_key For `SSE-KMS` and `CSE-KMS`, this is the KMS key ARN or ID.
#'        Default is `NULL` (no encryption)
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile profile name
#' @param polling_duration how often to check for results
#' @param max_time how long to keep looking for data
#' @param checktime whether to check for time
#' @return the filename
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.get_query_results>
#'
#' @export
#' @examples \dontrun{
#' execute_and_save_query(
#'   query    = "SELECT * FROM elb_logs LIMIT 100",
#'   database = "sampledb",
#'   profile  = "personal",
#'   output_location = "s3://aws-athena-query-results-redacted",
#'   local_filename = "download-to-here.csv",
#'   polling_duration = 15,
#'   checktime=FALSE,
#'   maxtime=1000
#'   )
#' }
#'
#'
execute_and_save_query <- function(query,
                                   database,
                                   output_location,
                                   local_filename,
                                   client_request_token = NULL,
                                   encryption_option = NULL,
                                   kms_key = NULL,
                                   aws_access_key_id = NULL,
                                   aws_secret_access_key = NULL,
                                   aws_session_token = NULL,
                                   region_name = NULL,
                                   profile_name = NULL,
                                   polling_duration = 15,
                                   checktime=FALSE,
                                   maxtime=1000
                                   ) {

  # create the query and obtain an executionID
  executionid <- start_query_execution(
    query=query,
    database=database,
    output_location=output_location,
    client_request_token = uuid::UUIDgenerate(),
    encryption_option = encryption_option,
    kms_key = kms_key,
    aws_access_key_id = aws_access_key_id,
    aws_secret_access_key = aws_secret_access_key,
    aws_session_token = aws_session_token,
    region_name = region_name,
    profile_name = profile_name
  )

  # use the execution ID to obtain the S3 path where the output data will be
  boto3$session$Session(
    aws_access_key_id = aws_access_key_id,
    aws_secret_access_key = aws_secret_access_key,
    aws_session_token = aws_session_token,
    region_name = region_name,
    profile_name = profile_name
  ) -> session

  client <- session$client("athena")
  res   <- client$get_query_execution(
    QueryExecutionId = executionid)


  # obtain the S3 output path
  s3     <- session$client("s3")
  s3path <- res$QueryExecution$ResultConfiguration$OutputLocation
  s3path <- gsub("s3://", "", s3path)
  bucket <- strsplit(s3path, "/")[[1]][[1]]
  s3key  <- paste(
    strsplit(s3path, "/")[[1]][-1],
    collapse = "/")


  # poll for the result; download when ready
  print("Initializing retrieval of Athena Query.")
  inittime <- Sys.time()

  s3obj <- NULL
  while(is.null(s3obj)) {

    # use existence of the download object as the trigger
    s3obj <- tryCatch(s3$head_object(Bucket=bucket, Key=s3key), error = function(e) NULL)

    Sys.sleep(polling_duration)
    duration <- Sys.time() - inittime
    print(duration)

    if (checktime==TRUE && abs(as.numeric(duration, units="mins"))  > maxtime ) {
      stop("Query has exceeded the maximum specified time")
    }
  }

  if (!is.null(s3obj)) {
    print(paste("downloading athena results file", s3path))
    s3$download_file(Bucket = bucket, Key = s3key , Filename = local_filename)
  }

  local_filename
}

