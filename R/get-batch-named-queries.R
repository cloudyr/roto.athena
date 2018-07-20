#' Get Query Execution (batch/multiple)
#'
#' Returns information about a single query.
#'
#' @md
#' @param named_query_ids character vector of 1-50 unique named query ids
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.batch_get_named_query>
#' @export
get_named_queries <- function(named_query_ids,
                              aws_access_key_id = NULL,
                              aws_secret_access_key = NULL,
                              aws_session_token = NULL,
                              region_name = NULL,
                              profile_name = NULL) {

  if (length(named_query_ids) > 50) {
    message("Limiting named query ids to 50")
    named_query_ids <- named_query_ids[1:50]
  }

  boto3$session$Session(
    aws_access_key_id = aws_access_key_id,
    aws_secret_access_key = aws_secret_access_key,
    aws_session_token = aws_session_token,
    region_name = region_name,
    profile_name = profile_name
  ) -> session

  client <- session$client("athena")

  client$batch_get_named_query(
    NamedQueryIds = as.list(named_query_ids)
  ) -> res

  do.call(
    rbind.data.frame,
    lapply(res$NamedQueries, function(.x) {
      data.frame(
        name = .x$Name %||% NA_character_,
        description = .x$Description %||% NA_character_,
        database = .x$Database %||% NA_character_,
        query_string = .x$QueryString %||% NA_character_,
        named_query_id = .x$NamedQueryId %||% NA_character_,
        stringsAsFactors = FALSE
      )
    })
  ) -> NamedQueries
  class(NamedQueries) <- c("tbl_df", "tbl", "data.frame")
  res$NamedQueries <- NamedQueries


  do.call(
    rbind.data.frame,
    lapply(y$UnprocessedNamedQueryIds, function(.x) {
      data.frame(
        named_query_id = .x$NamedQueryId %||% NA_character_,
        error_code = .x$ErrorCode %||% NA_character_,
        error_message = .x$ErrorMessage %||% NA_character_,
        stringsAsFactors = FALSE
      )
    })
  ) -> UnprocessedNamedQueryIds
  class(UnprocessedNamedQueryIds) <- c("tbl_df", "tbl", "data.frame")
  res$UnprocessedNamedQueryIds <- UnprocessedNamedQueryIds

  res

}

