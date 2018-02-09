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
          # returnObject <- TODO_OBJECT_MAPPING$new()
          # result <- returnObject$fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
          result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
          # Response$new(returnObject, resp)
          Response$new(result, resp)
        } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
          Response$new("API client error", resp)
        } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
          Response$new("API server error", resp)
        }

      },

      # overwrite swagger::M_ M_ A_ $new()$model_get
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
          # returnObject <- Character$new()
          # result <- returnObject$fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
          result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
          # Response$new(returnObject, resp)
          Response$new(result, resp)
        } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
          Response$new("API client error", resp)
        } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
          Response$new("API server error", resp)
        }

      }
    )
)
