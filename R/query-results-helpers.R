.get_query_results <- function(client, query_execution_id,
                               next_token,
                               max_results) {
  out <- list()

  if (is.null(next_token)) { # first call

    client$get_query_results(
      QueryExecutionId = query_execution_id,
      MaxResults = max_results
    ) -> res

    out <- c(out, list(res))

    while(!is.null(res$NextToken)) {
      res <- .get_query_results(client, query_execution_id, res$NextToken, max_results)
      out <- c(out, list(res))
    }

  } else {

    client$get_query_results(
      QueryExecutionId = query_execution_id,
      NextToken = next_token,
      MaxResults = max_results
    ) -> res

    return(res)

  }

  out

}

