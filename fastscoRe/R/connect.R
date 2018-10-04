#' Create an R6 "connect" class
#'
#' \code{connect} creates an R6 class with methods for connect operations;
#' it wraps \code{swagger::ConnectApi}
#'
#' @field $path Stores url path of the request.
#' @field $apiClient Handles the client-server communication.
#' @field $userAgent Set the user agent of the request.
#'
#' @section Methods:
#' \describe{
#'
#' \item{\code{$active_sensor_install()}}{install active sensor}
#'
#' \item{\code{$active_sensor_list()}}
#'
#' \item{\code{$active_sensor_points()}}
#'
#' \item{\code{$active_sensor_uninstall()}}
#'
#' \item{\code{$pneumo_get()}}
#' }
#'
#' @return An R6 class object
#'
#' @export
Connect <- R6::R6Class(
  classname = "Connect",
  public = list(
    userAgent = swagger::ConnectApi$public_fields$userAgent,
    apiClient = NULL,
    initialize = function(apiClient){
      if (!missing(apiClient)) {
        self$apiClient <- apiClient
      }
      else {
        self$apiClient <- ApiClient$new()
      }
      },
    active_sensor_install = function(instance, desc, ...){
      swagger::ConnectApi$public_methods$active_sensor_install(
        instance = instance, desc = desc, ...)
    },
    active_sensor_list = function(instance, ...){
      swagger::ConnectApi$public_methods$active_sensor_list(instance = instance, ...)
    },
    active_sensor_points = function(instance, ...){
      swagger::ConnectApi$public_methods$active_sensor_points(instance = instance, ...)
    },
    active_sensor_uninstall = function(instance, tap_id, ...){
      swagger::ConnectApi$public_methods$active_sensor_uninstall(
        instance = instance, tap_id = tap_id, ...)
    },
    pneumo_get = function(instance, ...){
      swagger::ConnectApi$public_methods$pneumo_get(instance = instance, ...)
    }


    )
)

