#' R client for the FastScore API
#'
#' An R6 class to instantiate an R client for the
#' FastScore API. Wraps R6 class generator \code{swaggerv2::ApiClient}
#'
#' @field name name for client
#' @field api name of API
#' @field basePath the HTTPS scheme URL for the FastScore Microservices
#' Dashboard being used for the FastScore instance you wish to connect to
#'
#' @return An R6 class instance, and R client for the FastScore API.
#'
#' @examples
#' api_cli <- fastscoRe::Instance$new(basePath = "https://localhost:8000")
#' @export
Instance <- R6::R6Class(
  classname = "Instance",
  public = list(
    basePath = swaggerv2::ApiClient$public_fields$basePath,
    configuration = NULL,
    userAgent = NULL,
    defaultHeaders = NULL,
    initialize = function(basePath, configuration, defaultHeaders){
      if (!missing(basePath)) {
        if(!grepl("://", basePath)) {
          stop("basePath must be an URL, e.g. 'https://dashboard:8000' ")
        }
        if(!grepl("https:", basePath)) {
          stop("basePath must use HTTPS scheme, e.g. 'https://dashboard:8000' ")
        }
        self$basePath <- paste0(
          basePath, "/", httr::parse_url(swaggerv2::ApiClient$public_fields$basePath)$path
          )
      }

      if (!missing(configuration)) {
        self$configuration <- configuration
      }

      if (!missing(defaultHeaders)) {
        self$defaultHeaders <- defaultHeaders
      }

      self$`userAgent` <- 'Swagger-Codegen/1.0.0/r'
    },
    callApi = function(url, method, queryParams, headerParams, body, ...){
      swaggerv2::ApiClient$public_methods$callApi(
        url = url, method = method, queryParams = queryParams,
        headerParams = headerParams, body = body, ...
      )
    }
    )
)
