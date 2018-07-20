#' Get Query Execution
#'
#' Returns information about a single execution of a query. Each time a query
#' executes, information about the query execution is saved with a unique ID.
#'
#' @md
#' @param query_execution_id unique ID of the query execution.
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.get_query_execution>
#' @export
get_query_execution <- function(query_execution_id,
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

  client$get_query_execution(
    QueryExecutionId = query_execution_id
  ) -> res

  data.frame(
    query_execution_id = res$QueryExecution$QueryExecutionId %||% NA_character_,
    query = res$QueryExecution$Query %||% NA_character_,
    output_location = res$QueryExecution$ResultConfiguration$OutputLocation %||% NA_character_,
    encryption_configuration = res$QueryExecution$ResultConfiguration$EncryptionOption %||% NA_character_,
    kms_key = res$QueryExecution$ResultConfiguration$KmsKey %||% NA_character_,
    database = res$QueryExecution$QueryExecutionContext$Database %||% NA_character_,
    state = res$QueryExecution$Status$State %||% NA_character_,
    state_change_reason = res$QueryExecution$StateChangeReason %||% NA_character_,
    submitted = as.character(res$QueryExecution$Status$SubmissionDateTime) %||% NA_character_,
    completed = as.character(res$QueryExecution$Status$CompletionDateTime) %||% NA_character_,
    execution_time_ms = res$QueryExecution$Statistics$EngineExecutionTimeInMillis %||% NA_integer_,
    bytes_scanned = res$QueryExecution$Statistics$DataScannedInBytes %||% NA_real_,
    stringsAsFactors = FALSE
  ) -> res

  class(res) <- c("tbl_df", "tbl", "data.frame")

  res

}

