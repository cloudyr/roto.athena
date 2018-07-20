
# aws.athena

Access Amazon’s AWS Athena API

## Description

Reticulated wrapper for the Python ‘boto3’ Athena client library.

## NOTE

This package **requires** Python \>= 3.5 to be available and the `boto3`
Python package.

## What’s Inside The Tin

The following functions are implemented:

  - `create_named_query`: Create a named query.
  - `delete_named_query`: Delete a named query.
  - `get_named_query`: Get Query Execution
  - `get_named_queries`: Get Query Execution (batch/multiple)
  - `get_query_execution`: Get Query Execution
  - `get_query_executions`: Get Query Executions (batch/multiple)
  - `get_query_results`: Get Query Results
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
library(tidyverse)

# current verison
packageVersion("aws.athena")
## [1] '0.1.0'
```

``` r
# see recent queries
x <- list_query_executions(profile = "personal")

head(x$QueryExecutionIds)
## [1] "85fbe683-c057-418b-b2f8-7508e41a04bc" "b972733d-21e4-42b8-873b-eac224c0a5b5" "4e83e27f-fa30-45bf-b6ce-f3e9c1a2b67d"
## [4] "57a1c9aa-ab55-4943-aaf4-b32b1d6b1433" "9b2f5e31-7134-4881-93df-f4f1ee240428" "91eaf6bb-a0cf-40e0-a791-b7edd811ab0b"

# get last 5 query executions
y <- get_query_executions(x$QueryExecutionIds[1:5], profile = "personal")

# only look at the ones that succeeded
filter(y$QueryExecutions, state == "SUCCEEDED") 
## # A tibble: 5 x 12
##   query_execution_… query  output_location encryption_conf… kms_key database state state_change_re… submitted completed
##   <chr>             <chr>  <chr>           <chr>            <chr>   <chr>    <chr> <chr>            <chr>     <chr>    
## 1 4e83e27f-fa30-45… SELEC… s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## 2 57a1c9aa-ab55-49… "SELE… s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## 3 85fbe683-c057-41… SELEC… s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## 4 9b2f5e31-7134-48… "SELE… s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## 5 b972733d-21e4-42… SELEC… s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## # ... with 2 more variables: execution_time_ms <int>, bytes_scanned <int>

# fire off another one!
start_query_execution(
  query = "SELECT * FROM elb_logs LIMIT 100",
  database = "sampledb",
  output_location = "s3://aws-athena-query-results-redacted",
  profile = "personal"
) -> sqe
```

``` r
# see the status
get_query_execution(sqe, profile = "personal") %>% 
  glimpse()
## Observations: 1
## Variables: 12
## $ query_execution_id       <chr> "ceaa0671-b6ec-4409-9a6d-1cd1c121496b"
## $ query                    <chr> "SELECT * FROM elb_logs LIMIT 100"
## $ output_location          <chr> "s3://aws-athena-query-results-redacted/ceaa0671-b6ec-4409-9a6d-1cd1c121496b.csv"
## $ encryption_configuration <chr> NA
## $ kms_key                  <chr> NA
## $ database                 <chr> "sampledb"
## $ state                    <chr> "SUCCEEDED"
## $ state_change_reason      <chr> NA
## $ submitted                <chr> "2018-07-20 08:04:55.038000-04:00"
## $ completed                <chr> "2018-07-20 08:04:56.855000-04:00"
## $ execution_time_ms        <int> 1589
## $ bytes_scanned            <int> 119110

# get the results
res <- get_query_results(sqe, profile = "personal")

res
## # A tibble: 100 x 16
##    timestamp   elbname requestip  requestport backendip  backendport requestprocessi… backendprocessi… clientresponset…
##    <chr>       <chr>   <chr>            <int> <chr>            <int>            <dbl>            <dbl>            <dbl>
##  1 2014-09-29… lb-demo 240.193.2…       13210 246.62.21…        8888        0.0000730           0.0241        0.0000470
##  2 2014-09-29… lb-demo 240.154.1…       40176 254.192.4…        8888        0.0000920           0.381         0.0000960
##  3 2014-09-29… lb-demo 245.155.2…       40176 255.209.3…        8888        0.000120            0.0166        0.0000830
##  4 2014-09-29… lb-demo 255.100.9…       53779 254.103.4…        8888        0.000104            0.0397        0.0000580
##  5 2014-09-29… lb-demo 246.62.21…       11810 254.103.4…        8888        0.0000860           0.0472        0.0000560
##  6 2014-09-29… lb-demo 254.103.4…       53376 242.220.9…        8888        0.0000600           0.0457        0.0000440
##  7 2014-09-29… lb-demo 240.147.1…       34693 250.234.1…         443        0.000101            0.0203        0.0000670
##  8 2014-09-29… lb-demo 251.69.22…       11810 251.69.22…        8888        0.0000720           0.0216        0.0000550
##  9 2014-09-29… lb-demo 242.190.1…       40176 245.155.2…          80        0.000106            0.0269        0.000201 
## 10 2014-09-29… lb-demo 248.228.9…       34693 248.178.1…        8888        0.000115            0.0154        0.0000890
## # ... with 90 more rows, and 7 more variables: elbresponsecode <chr>, backendresponsecode <chr>, receivedbytes <S3:
## #   integer64>, sentbytes <S3: integer64>, requestverb <chr>, url <chr>, protocol <chr>
```
