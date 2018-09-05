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
#' @param profile_name profile name
#' @param query_execution_id unique ID of the query execution.
#' @param filename download location of the athena result
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @return the filename
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.get_query_results>
#' @importFrom future future
#' @importFrom future resolved
#' @export
#' @examples \dontrun{
#' execute_and_save_query(
#'   query = "SELECT * FROM elb_logs LIMIT 100",
#'   database = "sampledb",
#'   output_location = "s3://aws-athena-query-results-redacted",
#'   profile = "personal"
#' )
#' }
#'
#'
execute_and_save_query <- function(query_execution_id,
                               filename,
                               aws_access_key_id = NULL,
                               aws_secret_access_key = NULL,
                               aws_session_token = NULL,
                               region_name = NULL,
                               profile_name = NULL) {

  executionid <- start_query_execution()
  localfile   <- future(save_query_results())

  value(localfile)
  }



}



