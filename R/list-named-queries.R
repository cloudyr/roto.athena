#' List Named Queries
#'
#' Provides a list of all available query IDs.
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
#' @export
list_named_queries <- function(max_results = 50L,
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
    client$list_named_queries(
      MaxResults = as.integer(max_results)
    ) -> res
  } else {
    client$list_named_queries(
      NextToken = next_token,
      MaxResults = as.integer(max_results)
    ) -> res
  }

  res

}

