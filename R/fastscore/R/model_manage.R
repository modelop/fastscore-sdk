# model_manage.py

ModelManage <- R6::R6Class("ModelManage",
    inherit = ModelManageApi, # swagger twin
    public = list(
      apiClient = NA,
      basePath = NA,
      initialize = function(apiClient, basePath = NA){
        self$apiClient <- apiClient # fastscore parent
        self$basePath <- apiClient$basePath
      }

    )


)
