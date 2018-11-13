#' FastScore Schema Class
#'
#' An R6 class generator for
#' FastScore schema object representations.
#
#' @title FastScore Schema Objects
#' @description fastscoRe::Schema$new()
#'
#' @field name A name for the schema
#' @field source the stream source code
#' @field model_manage the Model Manage instance, if any, the schema belongs to
#'
#' @importFrom R6 R6Class
#'
#' @section Methods:
#' \describe{
#' \item{\code{$method1()}}{}
#' \item{\code{$method2()}}{}
#' }
#'
#' @export
Schema <- R6::R6Class("Schema",
    public = list(
      name = NA,
      source = NA,
      model_manage = NA,

      initialize = function(name, source = NA, model_manage = NA){
        self$name <- name
        self$source <- readr::read_file(source)
        self$model_manage <- model_manage
      }
      )
    )
