#' Stop Query Execution
#'
#' Stops a query execution.
#'
#' @md
#' @param query_execution_id unique ID of the query execution.
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.stop_query_execution>
#' @export
stop_query_execution <- function(query_execution_id,
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

  client$stop_query_execution(
    QueryExecutionId = query_execution_id
  ) -> res

  res

}

