#' FastScore Engine (proxy) API Client
#'
#' An R6 class generator for Engine functions.
#' Inherits methods and fields from class
#' generator \code{swaggerv1::EngineApi}.
#'
#' @title FastScore Engine operations
#' @description fastscoRe::Engine
#'
#' @field path Stores url path of the request.
#' @field apiClient Handles the client-server communication.
#' @field userAgent Set the user agent of the request.
#'
#' @importFrom R6 R6Class
#'
#' @section Methods:
#' \describe{
#'
#' \item{\code{$health_get()}}{}
#'
#' \item{\code{$input_stream_set()}}{}
#'
#' \item{\code{$job_delete()}}{}
#'
#' \item{\code{$job_io_input()}}{}
#'
#' \item{\code{$job_io_input0()}}{}
#'
#' \item{\code{$job_io_output()}}{}
#'
#' \item{\code{$job_io_output1()}}{}
#'
#' \item{\code{$job_state_restore()}}{}
#'
#' \item{\code{$job_status()}}{}
#'
#' \item{\code{$model_load()}}{}
#'
#' \item{\code{$model_unload()}}{}
#'
#' \item{\code{$output_stream_set()}}{}
#'
#' \item{\code{$stream_attach()}}{}
#' }
#'
#' @export
Engine <- R6::R6Class(
  classname = "Engine",
  inherit = swaggerv1::EngineApi,
  public = list(
    apiClient = NA,
    basePath = NA,
    initialize = function(apiClient, basePath = NA){
      self$apiClient <- apiClient # fastscore parent
      self$basePath <- apiClient$basePath
      },
    model_load = function(
       instance, data, dry_run, content_type, content_disposition, ...
       ){
       args <- list(...)
       queryParams <- list()
       headerParams <- character()

       if (!missing(`content_type`)) {
         headerParams['Content-Type'] <- `content_type`
         # paste('x-model; name="', model$name, '"', sep='')
       }

       if (!missing(`content_disposition`)) {
         headerParams['Content-Disposition'] <- `content_disposition`
       }

       if (!missing(`dry_run`)) {
         queryParams['dry-run'] <- dry_run
       }

       if (!missing(`data`)) {
         body <- readr::read_file(data)
       } else {
         body <- NULL
       }

       urlPath <- "/{instance}/1/job/model"
       if (!missing(`instance`)) {
         urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
       }

       resp <- self$apiClient$callApi(
         url = paste0(self$apiClient$basePath, urlPath),
         method = "PUT",
         queryParams = queryParams,
         headerParams = headerParams,
         body = body, ...)

       if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
         Response$new(content = "Model successfully added.", response = resp)
       } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
         Response$new("API client error", response = resp)
       } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
         Response$new("API server error", response = resp)
       }

     },
    model_unload = function(instance, ...){
       args <- list(...)
       queryParams <- list()
       headerParams <- character()

       urlPath <- "/{instance}/2/active/model"
       if (!missing(`instance`)) {
         urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
       }

       resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                      method = "DELETE",
                                      queryParams = queryParams,
                                      headerParams = headerParams,
                                      body = body,
                                      ...)

       if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
         Response$new("Model successfully unloaded", resp)
       } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
         Response$new("API client error", resp)
       } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
         Response$new("API server error", resp)
       }
       }
    )
  )
