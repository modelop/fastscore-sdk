## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- eval = FALSE-------------------------------------------------------
#  > api_cli <- fastscoRe::Instance$new(basePath = "https://localhost:8000")
#  > api_cli
#  <Instance>
#    Public:
#      basePath: https://localhost:8000/api/1/service
#      callApi: function (url, method, queryParams, headerParams, body, ...)
#      clone: function (deep = FALSE)
#      configuration: NULL
#      defaultHeaders: NULL
#      initialize: function (basePath, configuration, defaultHeaders)
#      userAgent: Swagger-Codegen/1.0.0/r

## ---- eval = FALSE-------------------------------------------------------
#  > con <- fastscoRe::Connect$new(apiClient = api_cli)
#  > con
#  <Connect>
#    Public:
#      ...
#  
#  > con$health_get(instance = "connect")$response
#  Response [https://localhost:8000/api/1/service/connect/1/health]
#    Date: 2018-10-04 18:48
#    Status: 200
#    Content-Type: application/json
#    Size: 103 B
#  
#  >   resp <- con$health_get(instance = "connect")$response
#  >   httr::content(resp)
#  $release
#  [1] "1.7"
#  
#  $id
#  [1] "6b68c99b-a097-40c8-bfd5-df1cb660577a"
#  
#  $built_on
#  [1] "Mon Aug  6 22:46:32 UTC 2018"
#  
#  >   str(resp)
#  List of 10
#   $ url        : chr "https://localhost:8000/api/1/service/connect/1/health"
#   $ status_code: int 200
#   $ headers    :List of 7
#   ...
#  
#  >   resp$url
#  [1] "https://localhost:8000/api/1/service/connect/1/health"

## ---- fig.show='hold'----------------------------------------------------
plot(1:10)
plot(10:1)

