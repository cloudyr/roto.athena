#' List Query Executions
#'
#' Provides a list of all available query execution IDs.
#'
#' @md
#' @param max_results maximum number of query executions to return in this request
#' @param next_token token that specifies where to start pagination if a previous
#'        request was truncated.
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.list_query_executions>
#' @export
list_query_executions <- function(max_results = 50L,
                                  next_token = NULL,
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

  if (is.null(next_token)) {
    client$list_query_executions(
      MaxResults = as.integer(max_results)
    ) -> res
  } else {
    client$list_query_executions(
      NextToken = next_token,
      MaxResults = as.integer(max_results)
    ) -> res
  }

  res

}

