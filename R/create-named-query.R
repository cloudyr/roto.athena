#' Create a named query.
#'
#' @md
#' @param name plain language name for the query
#' @param description brief explanation of the query
#' @param query text of the query itself. In other words, all query statements
#' @param database database to which the query belongs
#' @param client_request_token unique case-sensitive string used to ensure the
#'        request to create the query is idempotent (executes only once). If another
#'        `CreateNamedQuery` request is received, the same response is returned
#'        and another query is not created. If a parameter has changed, for example,
#'        the `query` , an error is returned. **This is auto-generated-for-you**.
#' @param aws_access_key_id AWS access key id
#' @param aws_secret_access_key AWS secret access key
#' @param aws_session_token AWS session token
#' @param region_name region name
#' @param profile_name profile name
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.create_named_query>
#' @export
#' @examples \dontrun{
#' create_named_query(
#'   name = "elb100",
#'   description = "100 rows from elb_logs",
#'   query = "SELECT * FROM elb_logs LIMIT 100",
#'   database = "sampledb"
#' )
#' }
create_named_query <- function(name,
                               description,
                               query,
                               database,
                               client_request_token = uuid::UUIDgenerate(),
                               encryption_option = NULL,
                               kms_key = NULL,
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

  client$start_query_execution(
    Name = name,
    Description = description,
    Database = query,
    QueryString = database,
    ClientRequestToken = client_request_token
  ) -> res

  res$NamedQueryId

}
