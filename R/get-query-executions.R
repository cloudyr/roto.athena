#' Get Query Executions (batch/multiple)
#'
#' Returns the details of a single query execution or a list of up to 50 query
#' executions, which you provide as an array of query execution ID strings. To
#' get a list of query execution IDs, use [list_query_executions()]. Query
#' executions are different from named (saved) queries. Use
#' [batch_get_named_queries()] to get details about named queries.
#'
#' @md
#' @param query_execution_ids character vector of 1-50 unique query execution IDs.
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.batch_get_query_execution>
#' @export
get_query_executions <- function(query_execution_ids,
                                 aws_access_key_id = NULL,
                                 aws_secret_access_key = NULL,
                                 aws_session_token = NULL,
                                 region_name = NULL,
                                 profile_name = NULL) {

  if (length(query_execution_ids) > 50) {
    message("Limiting query execution ids to 50")
    query_execution_ids <- query_execution_ids[1:50]
  }

  boto3$session$Session(
    aws_access_key_id = aws_access_key_id,
    aws_secret_access_key = aws_secret_access_key,
    aws_session_token = aws_session_token,
    region_name = region_name,
    profile_name = profile_name
  ) -> session

  client <- session$client("athena")

  client$batch_get_query_execution(
    QueryExecutionIds = as.list(query_execution_ids)
  ) -> res

  do.call(
    rbind.data.frame,
    lapply(res$QueryExecutions, function(.x) {
      data.frame(
        query_execution_id = .x$QueryExecutionId %||% NA_character_,
        query = .x$Query %||% NA_character_,
        output_location = .x$ResultConfiguration$OutputLocation %||% NA_character_,
        encryption_configuration = .x$ResultConfiguration$EncryptionOption %||% NA_character_,
        kms_key = .x$ResultConfiguration$KmsKey %||% NA_character_,
        database = .x$QueryExecutionContext$Database %||% NA_character_,
        state = .x$Status$State %||% NA_character_,
        state_change_reason = .x$StateChangeReason %||% NA_character_,
        submitted = as.character(.x$Status$SubmissionDateTime) %||% NA_character_,
        completed = as.character(.x$Status$CompletionDateTime) %||% NA_character_,
        execution_time_ms = .x$Statistics$EngineExecutionTimeInMillis %||% NA_integer_,
        bytes_scanned = .x$Statistics$DataScannedInBytes %||% NA_real_,
        stringsAsFactors = FALSE
      )
    })
  ) -> QueryExecutions
  class(QueryExecutions) <- c("tbl_df", "tbl", "data.frame")
  res$QueryExecutions <- QueryExecutions

  do.call(
    rbind.data.frame,
    lapply(y$UnprocessedQueryExecutionIds, function(.x) {
      data.frame(
        query_execution_id = .x$QueryExecutionId %||% NA_character_,
        error_code = .x$ErrorCode %||% NA_character_,
        error_message = .x$ErrorMessage %||% NA_character_,
        stringsAsFactors = FALSE
      )
    })
  ) -> UnprocessedQueryExecutionIds
  class(UnprocessedQueryExecutionIds) <- c("tbl_df", "tbl", "data.frame")
  res$UnprocessedQueryExecutionIds <- UnprocessedQueryExecutionIds

  res

}

