#' FastScore Stream Class
#'
#' An R6 class generator for
#' FastScore stream object representations.
#
#' @title FastScore Stream Objects
#' @description fastscoRe::Stream$new()
#'
#' @field name A name for the stream
#' @field source the stream source code
#' @field model_manage the Model Manage instance, if any, the stream belongs to
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
Stream <- R6::R6Class(
  classname = "Stream",
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
