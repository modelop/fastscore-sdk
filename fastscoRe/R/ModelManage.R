#' FastScore Model Manage (proxy) API Client
#'
#' An R6 class generator for Model Manage functions.
#' Inherits methods and fields from class
#' generator \code{swaggerv1::ModelManageApi}.
#
#' @title ModelManage operations
#' @description fastscoRe::ModelManage
#'
#' @field path Stores url path of the request.
#' @field apiClient Handles the client-server communication.
#' @field userAgent Set the user agent of the request.
#'
#' @importFrom R6 R6Class
#'
#' @section Methods:
#' \describe{
#' \item{\code{$active_sensor_attach()}}{}
#' \item{\code{$active_sensor_available()}}{}
#' \item{\code{$active_sensor_describe()}}{}
#' \item{\code{$active_sensor_detach()}}{}
#' \item{\code{$active_sensor_list()}}{}
#' \item{\code{$attachment_delete()}}{}
#' \item{\code{$attachment_get()}}{overwrites \code{swaggerv1::ModelManageApi$attachment_get()}}
#' \item{\code{$attachment_head()}}{}
#' \item{\code{$attachment_list()}}{}
#' \item{\code{$attachment_put()}}{}
#' \item{\code{$health_get()}}{}
#' \item{\code{$model_delete()}}{}
#' \item{\code{$model_get()}}{overwrites \code{swaggerv1::ModelManageApi$model_get()}}
#' \item{\code{$model_list()}}{overwrites \code{swaggerv1::ModelManageApi$model_list()}}
#' \item{\code{$model_put()}}{overwrites \code{swaggerv1::ModelManageApi$model_put()}}
#' \item{\code{$schema_delete()}}{}
#' \item{\code{$schema_get()}}{overwrites \code{swaggerv1::ModelManageApi$schema_get()}}
#' \item{\code{$schema_list()}}{}
#' \item{\code{$schema_put()}}{}
#' \item{\code{$sensor_delete()}}{}
#' \item{\code{$sensor_get()}}{}
#' \item{\code{$sensor_list()}}{}
#' \item{\code{$sensor_put()}}{}
#' \item{\code{$snapshot_delete()}}{}
#' \item{\code{$snapshot_get()}}{}
#' \item{\code{$snapshot_get_contents()}}{}
#' \item{\code{$snapshot_get_metadata()}}{}
#' \item{\code{$snapshot_list()}}{}
#' \item{\code{$snapshot_put()}}{}
#' \item{\code{$stream_delete()}}{}
#' \item{\code{$stream_get()}}{overwrites \code{swaggerv1::ModelManageApi$stream_get()}
#' \item{\code{$stream_list()}}{overwrites \code{swaggerv1::ModelManageApi$stream_list()}
#' \item{\code{$stream_put()}}{IN PROGRESS}
#' \item{\code{$swagger_get()}}{overwrites \code{swaggerv1::ModelManageApi$swagger_get()}
#' }
#'
#' @export
ModelManage <- R6::R6Class(
  classname = "ModelManage",
  inherit = swaggerv1::ModelManageApi, # **
  public = list(
    userAgent = "Swagger-Codegen/1.0.0/r",
    apiClient = NULL,
    initialize = function(apiClient){
      if (!missing(apiClient)) {
        self$apiClient <- apiClient
        }
      else {
        self$apiClient <- swaggerv2::ApiClient$new()
        }
      },
    attachment_get = function(instance, model, attachment, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/model/{model}/attachment/{attachment}"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      if (!missing(`model`)) {
        urlPath <- gsub(paste0("\\{", "model", "\\}"), `model`, urlPath)
      }

      if (!missing(`attachment`)) {
        urlPath <- gsub(paste0("\\{", "attachment", "\\}"), `attachment`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "GET",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        result <- returnObject$fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        Response$new(result, resp)
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },

    model_put = function(instance, model, source, content_type, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`content_type`)) {
        headerParams['Content-Type'] <- `content_type`
      }

      if (!missing(`source`)) {
        body <- readr::read_file(source)
      } else {
        body <- NULL
      }

      urlPath <- "/{instance}/1/model/{model}"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      if (!missing(`model`)) {
        urlPath <- gsub(paste0("\\{", "model", "\\}"), `model`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "PUT",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        # void response, no need to return anything
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },
    model_list = function(instance, return, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`return`)) {
        queryParams['return'] <- return
      }

      urlPath <- "/{instance}/1/model"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "GET",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        Response$new(result, resp)
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },
    model_get = function(instance, model, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/model/{model}"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      if (!missing(`model`)) {
        urlPath <- gsub(paste0("\\{", "model", "\\}"), `model`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "GET",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        # result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        result <- httr::content(resp, "text", encoding = "UTF-8")
        Response$new(cat(result), resp)
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },

    schema_get = function(instance, schema, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/schema/{schema}"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      if (!missing(`schema`)) {
        urlPath <- gsub(paste0("\\{", "schema", "\\}"), `schema`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "GET",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        Response$new(result, resp)
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },

    stream_list = function(instance, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/stream"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "GET",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        Response$new(result, resp)
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },
    stream_get = function(instance, stream, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/stream/{stream}"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      if (!missing(`stream`)) {
        urlPath <- gsub(paste0("\\{", "stream", "\\}"), `stream`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "GET",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        Response$new(result, resp)
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },
    stream_put = function(instance, stream, desc, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`desc`)) {
        body <- readr::read_file(desc) # stream descriptor
      } else {
        body <- NULL
      }

      urlPath <- "/{instance}/1/stream/{stream}"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      if (!missing(`stream`)) {
        urlPath <- gsub(paste0("\\{", "stream", "\\}"), `stream`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "PUT",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        # void response, no need to return anything
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },

    swagger_get = function(instance, accept, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`accept`)) {
        headerParams['Accept'] <- `accept`
      }

      urlPath <- "/{instance}/1/swagger"
      if (!missing(`instance`)) {
        urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "GET",
                                     queryParams = queryParams,
                                     headerParams = headerParams,
                                     body = body,
                                     ...)

      if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
        result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        Response$new(result, resp)
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    }
    )
  )
