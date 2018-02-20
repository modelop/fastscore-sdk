#' RC implementation of Queue
#'
#' A simple example of what is possible using roxygen 4.1.1
#'
#' @field queue a list of items in the queue
#' @examples
#' (qrc <- QueueRC(5, 6, "foo"))
#' qrc$add("add something")
#' qrc$add("and something else")
#' qrc$remove()
#' @export

ModelManage <- R6::R6Class("ModelManage",
    inherit = ModelManageApi, # swagger twin
    public = list(
      apiClient = NA,
      basePath = NA,
      initialize = function(apiClient, basePath = NA){
        self$apiClient <- apiClient # fastscore parent
        self$basePath <- apiClient$basePath
      },

      # overwrite swagger::ModelManageApi$new()$model_list()
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

      # overwrite swagger::ModelManageApi$model_get
      model_get = function(instance, model, ...){
        args <- list(...)
        queryParams <- list()
        headerParams <- character()

        urlPath <- "/{instance}/1/model/{model}"

        if (!missing(`instance`)) {
          urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
        } # e.g. "/model-manage-1/1/model/{model}"

        if (!missing(`model`)) {
          urlPath <- gsub(paste0("\\{", "model", "\\}"), `model`, urlPath)
        } # e.g. "/model-manage-1/1/model/hello-world"

        resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                       method = "GET",
                                       queryParams = queryParams,
                                       headerParams = headerParams,
                                       body = body,
                                       ...)

        if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
          result <- httr::content(resp, "text", encoding = "UTF-8")
          Response$new(result, resp)

        } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
          Response$new("API client error", resp)
        } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
          Response$new("API server error", resp)
        }

      },

      # overwrite swagger::ModelManageApi$schema_list b/c missing Character class
      schema_list = function(instance, ...){
        args <- list(...)
        queryParams <- list()
        headerParams <- character()

        urlPath <- "/{instance}/1/schema"
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

          # returnObject <- Character$new()
          # result <- returnObject$fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
          # Response$new(returnObject, resp)

          result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
          Response$new(result, resp)

        } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
          Response$new("API client error", resp)
        } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
          Response$new("API server error", resp)
        }

      },

      # overwrite unfinished swagger::ModelManageApi$schema_get
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

          # returnObject <- TODO_OBJECT_MAPPING$new()
          # result <- returnObject$fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
          # Response$new(returnObject, resp)

          result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
          Response$new(result, resp)

        } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
          Response$new("API client error", resp)
        } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
          Response$new("API server error", resp)
        }

      },

      # overwrite swagger::ModelManageApi$schema_put
      # ...add rjson::toJSON()
      schema_put = function(instance, schema, source, ...){ # ****************
        args <- list(...)
        queryParams <- list()
        headerParams <- character()

        # converts 'source' to JSON
        if (!missing(`source`)) {
          body <- rjson::toJSON(`source`)
        } else {
          body <- NULL
        }

        urlPath <- "/{instance}/1/schema/{schema}"
        if (!missing(`instance`)) {
          urlPath <- gsub(paste0("\\{", "instance", "\\}"), `instance`, urlPath)
        }

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
          Response$new("New schema successfully added or updated.", resp)
        } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
          Response$new("API client error", resp)
        } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
          Response$new("API server error", resp)
        }

      },

      # overwrite swagger::ModelManageApi$schema_delete,
      # ...add Response$new() for http response 204
      schema_delete = function(instance, schema, ...){
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
                                       method = "DELETE",
                                       queryParams = queryParams,
                                       headerParams = headerParams,
                                       body = body,
                                       ...)

        if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
          Response$new("Schema successfully deleted.", resp)
        } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
          Response$new("API client error", resp)
        } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
          Response$new("API server error", resp)
        }

      },

      # overwrite swagger::ModelManageAoi$model_put
      # remove toJSON
      model_put = function(instance, model, source, content_type, ...){
        args <- list(...)
        queryParams <- list()
        headerParams <- character()

        if (!missing(`content_type`)) {
          headerParams['Content-Type'] <- `content_type`
        }

        if (!missing(`source`)) {
          body <- `source`
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
          Response$new("Model successfully added/updated", resp)
        } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
          Response$new("API client error", resp)
        } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
          Response$new("API server error", resp)
        }

      }



    )
)
