#' Create an R6 "connect" class
#'
#' \code{connect} creates an R6 class with methods for connect operations;
#' inherits from \code{swaggerv1::ConnectApi}
#'
#' @field $path Stores url path of the request.
#' @field $apiClient Handles the client-server communication.
#' @field $userAgent Set the user agent of the request.
#'
#' @section Methods:
#' \describe{
#' \item{\code{$active_sensor_install()}}{install active sensor}
#' \item{\code{$active_sensor_list()}}{}
#' \item{\code{$active_sensor_points()}}{}
#' \item{\code{$active_sensor_uninstall()}}{}
#' \item{\code{$pneumo_get()}}{}
#' \item{\code{$connect_get()}}{}
#' \item{\code{$health_get()}}{}
#' \item{\code{$swagger_get()}}{}
#' }
#'
#' @return An R6 class object
#'
#' @export
Connect <- R6::R6Class(
  classname = "Connect",
  inherit = swaggerv1::ConnectApi,
  public = list(
    userAgent = swaggerv2::ConnectApi$public_fields$userAgent,
    apiClient = NULL,
    initialize = function(apiClient){
      if (!missing(apiClient)) {
        self$apiClient <- apiClient
      }
      else {
        self$apiClient <- ApiClient$new()
      }
      }
    )
  )

