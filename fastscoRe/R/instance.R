#' R client for the FastScore API
#'
#' An R6 class to instantiate an R client for the
#' FastScore API. Wraps R6 class generator swagger::ApiClient
#'
#' @field name
#' @field api
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
  inherit = swagger::ApiClient,
  public = list(
    name = NA,
    api = NA,
    basePath = NA,

      initialize = function(name = NA, api = NA, basePath){

        if(!grepl("://", basePath)) {
          stop("basePath must be an URL, e.g. 'https://dashboard:8000' ")
          }
        if(!grepl("https:", basePath)) {
          stop("basePath must use HTTPS scheme, e.g. 'https://dashboard:8000' ")
        }

        self$name <- name
        self$api <- api
        self$basePath <- paste0(basePath, "/", httr::parse_url(swagger::ApiClient$new()$basePath)$path)
      }

    )
)
