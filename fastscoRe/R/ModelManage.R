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
#' \item{\code{$attachment_get()}}{overwrites \code{swaggerv1::ModelManageApi$attachment_get()}; saves attachment to file of same name, in current working directory}
#' \item{\code{$attachment_head()}}{}
#' \item{\code{$attachment_list()}}{}
#' \item{\code{$attachment_put()}}{IN PROGRESS}
#' \item{\code{$health_get()}}{}
#' \item{\code{$model_delete()}}{}
#' \item{\code{$model_get()}}{overwrites \code{swaggerv1::ModelManageApi$model_get()}}
#' \item{\code{$model_list()}}{overwrites \code{swaggerv1::ModelManageApi$model_list()}}
#' \item{\code{$model_put()}}{overwrites \code{swaggerv1::ModelManageApi$model_put()}}
#' \item{\code{$schema_delete()}}{}
#' \item{\code{$schema_get()}}{overwrites \code{swaggerv1::ModelManageApi$schema_get()}}
#' \item{\code{$schema_list()}}{overwrites \code{swaggerv1::ModelManageApi$schema_list()}}
#' \item{\code{$schema_put()}}{overwrites \code{swaggerv1::ModelManageApi$schema_put()}}
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
#' \item{\code{$stream_get()}}{overwrites \code{swaggerv1::ModelManageApi$stream_get()}}
#' \item{\code{$stream_list()}}{overwrites \code{swaggerv1::ModelManageApi$stream_list()}}
#' \item{\code{$stream_put()}}{overwrites \code{swaggerv1::ModelManageApi$stream_put()}}
#' \item{\code{$swagger_get()}}{overwrites \code{swaggerv1::ModelManageApi$swagger_get()}}
#' }
#'
#' @export
ModelManage <- R6::R6Class(
  classname = "ModelManage",
  inherit = swaggerv1::ModelManageApi, # **
  public = list(
    userAgent = "Swagger-Codegen/1.0.0/r",
    apiClient = NULL,
    instance = NULL,
    initialize = function(apiClient, instance){

      if (!missing(apiClient)) {
        self$apiClient <- apiClient
        } else {
        self$apiClient <- swaggerv2::ApiClient$new()
        }

      if(!missing(instance)){
        self$instance <- instance
      } else {
        stop("Please specify instance. e.g. instance = 'model-manage-1' ")
      }

      },

    # MODEL
    model_put = function(model, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      # Verify 'Model' class
      if(!("Model" %in% class(model))){
        stop("$model_put() requires a 'Model' class object")
      }

      # Model type
      if(!(model$mtype %in% names(MODEL_CONTENT_TYPES))){
        stop("Model type must be one of: 'pfa-json', 'pfa-yaml', 'pfa-pretty', 'h2o-java', 'python', 'python3', 'R', 'java', or 'c' ")
          } else{
        headerParams['Content-Type'] <- MODEL_CONTENT_TYPES[[model$mtype]]
        }

      # Model 'source' code
      body <- readr::read_file(model$source)

      urlPath <- "/{instance}/1/model/{model}"

      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)

      urlPath <- gsub(paste0("\\{", "model", "\\}"), model$name, urlPath)

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
    model_list = function(return, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`return`)) {
        queryParams['return'] <- return
      }

      urlPath <- paste0("/", self$instance, "/1/model")

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
    model_get = function(model, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/model/{model}"

      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)

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
    model_delete = function(model, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/model/{model}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)

      if (!missing(`model`)) {
        urlPath <- gsub(paste0("\\{", "model", "\\}"), `model`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "DELETE",
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

    # SCHEMA
    schema_list = function(...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/schema"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


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
    schema_get = function(schema, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/schema/{schema}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


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
    schema_put = function(schema, source, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`source`)) {
        body <- readr::read_file(source)
      } else {
        body <- NULL
      }

      urlPath <- "/{instance}/1/schema/{schema}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


      if (!missing(`schema`)) {
        urlPath <- gsub(paste0("\\{", "schema", "\\}"), `schema`, urlPath)
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
    schema_delete = function(schema, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/schema/{schema}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


      if (!missing(`schema`)) {
        urlPath <- gsub(paste0("\\{", "schema", "\\}"), `schema`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "DELETE",
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

    # STREAM
    stream_list = function(...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/stream"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


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
    stream_get = function(stream, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/stream/{stream}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


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
    stream_put = function(stream, desc, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`desc`)) {
        body <- readr::read_file(desc) # stream descriptor
      } else {
        body <- NULL
      }

      urlPath <- "/{instance}/1/stream/{stream}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


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
    stream_delete = function(stream, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/stream/{stream}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


      if (!missing(`stream`)) {
        urlPath <- gsub(paste0("\\{", "stream", "\\}"), `stream`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "DELETE",
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

    # ATTACHMENT
    attachment_list = function(model, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/model/{model}/attachment"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


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
        result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
        Response$new(result, resp)
      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },
    attachment_get = function(model, attachment, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/model/{model}/attachment/{attachment}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


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

        f <- file(attachment, "wb")
        writeBin(httr::content(resp, encoding = "UTF-8"), con = f)
        close(f)
        print(paste("Attachment downloaded as", attachment))
        Response$new("See file: model.tar.gz", response = resp)

      } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
        Response$new("API client error", resp)
      } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
        Response$new("API server error", resp)
      }

    },
    attachment_put = function(model, attachment, attachment_file, content_type, ...){
      # attachment = attachment name

      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`content_type`)) {
        headerParams['Content-Type'] <- `content_type`
      }
      else if(tools::file_ext(attachment_file) == 'zip'){
        headerParams['Content-Type'] <- 'application/zip'
      }
      else if(tools::file_ext(attachment_file) == 'gz'){
        headerParams['Content-Type'] <- 'application/gzip'
      }
      else{
        stop(paste('Attachment content_type not provided, and attachment does not have a known extension (.zip or .gz)'))
        }

      if(!file.exists(attachment_file)){
        stop(paste('Attachment', attachment_file, 'not found'))
      }

      if (!missing(`attachment_file`)) {
        body <- httr::upload_file(attachment_file)
      } else {
        body <- NULL
      }

      urlPath <- "/{instance}/1/model/{model}/attachment/{attachment}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


      if (!missing(`model`)) {
        urlPath <- gsub(paste0("\\{", "model", "\\}"), `model`, urlPath)
      }

      if (!missing(`attachment`)) {
        urlPath <- gsub(paste0("\\{", "attachment", "\\}"), `attachment`, urlPath)
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
    attachment_delete = function(model, attachment, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      urlPath <- "/{instance}/1/model/{model}/attachment/{attachment}"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)

      if (!missing(`model`)) {
        urlPath <- gsub(paste0("\\{", "model", "\\}"), `model`, urlPath)
      }

      if (!missing(`attachment`)) {
        urlPath <- gsub(paste0("\\{", "attachment", "\\}"), `attachment`, urlPath)
      }

      resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                     method = "DELETE",
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

    swagger_get = function(accept, ...){
      args <- list(...)
      queryParams <- list()
      headerParams <- character()

      if (!missing(`accept`)) {
        headerParams['Accept'] <- `accept`
      }

      urlPath <- "/{instance}/1/swagger"
      urlPath <- gsub(paste0("\\{", "instance", "\\}"), self$instance, urlPath)


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
