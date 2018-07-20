#' Start Query Execution
#'
#' Runs (executes) the SQL query statements contained in the `query` string.
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
#' @references <https://boto3.readthedocs.io/en/latest/reference/services/athena.html#Athena.Client.start_query_execution>
#' @export
#' @examples \dontrun{
#' start_query_execution(
#'   query = "SELECT * FROM elb_logs LIMIT 100",
#'   database = "sampledb",
#'   output_location = "s3://aws-athena-query-results-redacted",
#'   profile = "personal"
#' ) -> sqe
#' }
start_query_execution <- function(query,
                                  database,
                                  output_location,
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

  if (is.null(encryption_option)) {

    client$start_query_execution(
      QueryString = query,
      ClientRequestToken = client_request_token,
      QueryExecutionContext = list(Database = database),
      ResultConfiguration = list(OutputLocation = output_location)
    ) -> res

  } else {

    if (is.null(kms_key)) {

      client$start_query_execution(
        QueryString = query,
        ClientRequestToken = client_request_token,
        QueryExecutionContext = list(Database = database),
        ResultConfiguration = list(
          OutputLocation = output_location,
          EncryptionConfiguration = list(
            EncryptionOption = encryption_option
          )
        )
      ) -> res

    } else {

      client$start_query_execution(
        QueryString = query,
        ClientRequestToken = client_request_token,
        QueryExecutionContext = list(Database = database),
        ResultConfiguration = list(
          OutputLocation = output_location,
          EncryptionConfiguration = list(
            EncryptionOption = encryption_option,
            KmsKey = kms_key
          )
        )
      ) -> res

    }

  }

  res$QueryExecutionId

}
