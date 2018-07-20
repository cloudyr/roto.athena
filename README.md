
# roto.athena

Perform and Manage 'Amazon' 'Athena' Queries 

## Description

This is a 'reticulated' wrapper for the 'Python' 'boto3' 'AWS' 'Athena' client library <https://boto3.readthedocs.io/en/latest/reference/services/athena.html>. It requires 'Python' version 3.5+ and an 'AWS' account. Tools are also provided to execute 'dplyr' chains asynchronously.

## NOTE

This package **requires** Python \>= 3.5 to be available and the `boto3` Python module. The package author highly recommends setting `RETICULATE_PYTHON=/usr/local/bin/python3` in your `~/.Renviron` file to ensure R + `reticulate` will use the proper python version.

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
  - `collect_async`:  Collect Amazon Athena `dplyr` query results asynchronously

## Installation

``` r
devtools::install_github("hrbrmstr/roto.athena")
# OR
devtools::install_git("git://gitlab.com/hrbrmstr/roto.athena")
```

## Usage

``` r
library(roto.athena)
library(tidyverse)

# current verison
packageVersion("aws.athena")
## [1] '0.1.0'
```

### Basic Usage

``` r
# see recent queries
x <- list_query_executions(profile = "personal")

head(x$QueryExecutionIds)
## [1] "25672eb3-418a-496d-b9c0-afe93b774009" "719dd084-f940-4cb4-931e-35688575bc6e" "0e6f6e17-4432-4332-9f0e-ee85ec70f1a0"
## [4] "92768c3f-eabc-4c72-b61e-244ee72e8810" "9b02fd64-3c1b-404c-bba0-a23d62ec28d0" "1ee48b6a-735b-4f66-b526-093047d07e78"

# get last 5 query executions
y <- get_query_executions(x$QueryExecutionIds[1:5], profile = "personal")

# only look at the ones that succeeded
filter(y$QueryExecutions, state == "SUCCEEDED") 
## # A tibble: 5 x 12
##   query_execution_… query  output_location encryption_conf… kms_key database state state_change_re… submitted completed
##   <chr>             <chr>  <chr>           <chr>            <chr>   <chr>    <chr> <chr>            <chr>     <chr>    
## 1 92768c3f-eabc-4c… SHOW … s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## 2 0e6f6e17-4432-43… SHOW … s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## 3 25672eb3-418a-49… "SELE… s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## 4 719dd084-f940-4c… "SELE… s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
## 5 9b02fd64-3c1b-40… SHOW … s3://aws-athen… <NA>             <NA>    sampledb SUCC… <NA>             2018-07-… 2018-07-…
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
## Variables: 10
## $ query_execution_id  <chr> "0b6d4b0c-a2e8-4896-aa78-679a5ff2ba7d"
## $ query               <chr> "SELECT * FROM elb_logs LIMIT 100"
## $ output_location     <chr> "s3://aws-athena-query-results-redacted/0b6d4b0c-a2e8-4896-aa78-679a5ff2ba7d.csv"
## $ database            <chr> "sampledb"
## $ state               <chr> "SUCCEEDED"
## $ state_change_reason <chr> NA
## $ submitted           <chr> "2018-07-20 09:43:56.993000-04:00"
## $ completed           <chr> "2018-07-20 09:43:58.844000-04:00"
## $ execution_time_ms   <int> 1610
## $ bytes_scanned       <int> 288722

# get the results
res <- get_query_results(sqe, profile = "personal")

res
## # A tibble: 100 x 16
##    timestamp   elbname requestip  requestport backendip  backendport requestprocessi… backendprocessi… clientresponset…
##    <chr>       <chr>   <chr>            <int> <chr>            <int>            <dbl>            <dbl>            <dbl>
##  1 2014-09-26… lb-demo 245.74.18…       27026 253.8.255…        8888        0.0000780           0.0365        0.0000470
##  2 2014-09-26… lb-demo 249.90.14…       20670 253.25.5.…        8888        0.0000940           0.0213        0.0000480
##  3 2014-09-26… lb-demo 251.164.1…       27026 248.118.6…        8888        0.000104            0.0391        0.0000550
##  4 2014-09-26… lb-demo 245.163.9…       20670 253.25.5.…         443        0.000114            0.0532        0.0000660
##  5 2014-09-26… lb-demo 252.248.6…       27026 250.238.2…        8888        0.0000890           0.0401        0.0000450
##  6 2014-09-26… lb-demo 252.222.3…       20670 249.90.14…        8888        0.0000910           0.0386        0.0000410
##  7 2014-09-26… lb-demo 251.138.2…       27026 253.25.5.…        8899        0.0000920           0.0485        0.0000690
##  8 2014-09-26… lb-demo 243.35.14…       20670 242.76.95…        8888        0.000115            0.0409        0.0000710
##  9 2014-09-26… lb-demo 251.130.1…       27026 248.81.19…          80        0.0000900           0.0405        0.0000550
## 10 2014-09-26… lb-demo 251.130.1…       20670 251.214.2…        8888        0.000104            0.0403        0.0000520
## # ... with 90 more rows, and 7 more variables: elbresponsecode <chr>, backendresponsecode <chr>, receivedbytes <S3:
## #   integer64>, sentbytes <S3: integer64>, requestverb <chr>, url <chr>, protocol <chr>
```

### Async `dplyr` calls

``` r
library(odbc)
library(DBI)

DBI::dbConnect(
  odbc::odbc(), 
  driver = "/Library/simba/athenaodbc/lib/libathenaodbc_sbu.dylib", 
  Schema = "sampledb",
  AwsRegion = "us-east-1",
  AwsProfile = "personal",
  AuthenticationType = "IAM Profile",
  S3OutputLocation = "s3://aws-athena-query-results-redacted"
) -> con

elb_logs <- tbl(con, "elb_logs")

mutate(elb_logs, tsday = substr(timestamp, 1, 10)) %>% 
  filter(tsday == "2014-09-29") %>%
  select(requestip, requestprocessingtime) %>% 
  collect_async(
    database = "sampledb", 
    output_location = "s3://aws-athena-query-results-redacted",
    profile_name = "personal"
  ) -> id
```

``` r
get_query_execution(id, profile = "personal") %>% 
  glimpse()
## Observations: 1
## Variables: 10
## $ query_execution_id  <chr> "2c54e526-8dda-4250-bda0-35853603eda9"
## $ query               <chr> "SELECT \"requestip\", \"requestprocessingtime\"\nFROM (SELECT *\nFROM (SELECT \"timest...
## $ output_location     <chr> "s3://aws-athena-query-results-redacted/2c54e526-8dda-4250-bda0-35853603eda9.csv"
## $ database            <chr> "sampledb"
## $ state               <chr> "SUCCEEDED"
## $ state_change_reason <chr> NA
## $ submitted           <chr> "2018-07-20 09:44:03.982000-04:00"
## $ completed           <chr> "2018-07-20 09:44:05.239000-04:00"
## $ execution_time_ms   <int> 1147
## $ bytes_scanned       <int> 846383

get_query_results(id, profile = "personal")
## # A tibble: 774 x 2
##    requestip       requestprocessingtime
##    <chr>                           <dbl>
##  1 240.193.27.4                0.0000730
##  2 240.154.14.237              0.0000920
##  3 245.155.219.217             0.000120 
##  4 255.100.99.136              0.000104 
##  5 246.62.216.54               0.0000860
##  6 254.103.46.154              0.0000600
##  7 240.147.146.84              0.000101 
##  8 251.69.22.230               0.0000720
##  9 242.190.162.43              0.000106 
## 10 248.228.92.236              0.000115 
## # ... with 764 more rows
```
