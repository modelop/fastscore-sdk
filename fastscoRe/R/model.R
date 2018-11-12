#' FastScore Model Class
#'
#' An R6 class generator for
#' FastScore model object representations.
#
#' @title FastScore Model Objects
#' @description fastscoRe::Model$new()
#'
#' @field name A name for the model
#' @field mtype model type; e.g. 'R'
#' @field source the model code
#' @field model_manage the Model Manage instance the model belongs to
#'
#' @importFrom R6 R6Class
#'
#' @section Methods:
#' \describe{
#' \item{\code{$attachment_list}}{}
#' \item{\code{$attachment_get()}}{}
#' \item{\code{$attachment_download()}}{}
#' \item{\code{$attachment_delete()}}{}
#' }
#'
#' @export
Model <- R6::R6Class(
  classname = "Model",
  public = list(
    name = NULL,
    mtype = NA,
    source = NA,
    model_manage = NA,

    initialize = function(name, mtype = NA, source = NA, model_manage = NA){
       self$name <- name
       self$mtype <- mtype
       self$source <- readr::read_file(source)
       self$model_manage <- model_manage
     },

    attachment_list = function(){
        if(!is.null(self$model_manage)){
          self$model_manage$attachment_list(self$name)
        }
        else{
          stop("FastScoreError: Model is not associated with Model Manage")
        }
  },
    attachment_get = function(name){
        stop("Not implemented!") # TODO
  },
    attachment_download = function(name){
        stop("Not implemented!") # TODO
  },
    attachment_delete = function(name){
        stop("Not implemented!") # TODO
  }
  )
)
