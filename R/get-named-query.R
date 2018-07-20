#' Get Query Execution
#'
#' Returns information about a single query.
#'
#' @md
#' @param named_query_id unique ID of the named query
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.get_named_query>
#' @export
#' @examples \dontrun{
#' res <- list_named_queries()
#'
#' get_named_query(res$NamedQueryIds[1])
#' }
get_named_query <- function(named_query_id,
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

  client$get_named_query(
    NamedQueryId = named_query_id
  ) -> res

  data.frame(
    name = res$NamedQuery$Name %||% NA_character_,
    description = res$NamedQuery$Description %||% NA_character_,
    database = res$NamedQuery$Database %||% NA_character_,
    query_string = res$NamedQuery$QueryString %||% NA_character_,
    named_query_id = res$NamedQuery$NamedQueryId %||% NA_character_,
    stringsAsFactors = FALSE
  ) -> res

  class(res) <- c("tbl_df", "tbl", "data.frame")

  res

}

