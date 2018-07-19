
# aws.athena

Access Amazon’s AWS Athena API

## Description

Reticulated wrapper for the Python ‘boto3’ Athena client library.

## NOTE

This package **requires** Python \>= 3.5 to be available and the `boto3`
Python package.

## What’s Inside The Tin

The following functions are implemented:

  - `get_named_query`: Get Query Execution
  - `get_query_execution`: Get Query Execution
  - `list_named_queries`: List Named Queries
  - `list_query_executions`: List Query Executions
  - `start_query_execution`: Start Query Execution
  - `stop_query_execution`: Stop Query Execution

## Installation

``` r
devtools::install_github("hrbrmstr/aws.athena")
```

## Usage

``` r
library(aws.athena)

# current verison
packageVersion("aws.athena")
```

    ## [1] '0.1.0'
