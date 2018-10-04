# Working on R-SDK built on swagger-codegen generated client ("swagger")

# devtools ======
library(help = "swagger")
# devtools::build_vignettes()


# ignore self-certify  ========
# httr::GET(url = paste0(basePath, urlPath),
#           config = httr::config(ssl_verifypeer = FALSE))
# ...inside of ApiClient$ConnectApi$health_get to ignore "self certify"

httr::set_config(httr::config(ssl_verifypeer = FALSE)) # global ignore-self-certify config

# Instance$new(), Connect$new() =======
api_cli <- fastscoRe::Instance$new(basePath = "https://localhost:8000")
con <- fastscoRe::Connect$new(apiClient = api_cli)

# ModelManageApi$new(...) =======
modman <- fastscoRe::ModelManage$new(apiClient = api_cli)

  modman$model_list(instance = "model-manage-1")
  modman$model_get(instance = "model-manage-1", model = "auto_gbm")
  # getting "lexical error"
  modman$stream_get(instance = "model-manage-1", stream = "rest-in")

  strmlist <- modman$stream_list(instance = "model-manage-1")
    strmlist$content # [1] "demo-1"   "demo-2"   "rest-in"  "rest-out"

# EngingeApi$new(...) =========
eng <- swagger::EngineApi$new(apiClient = api_cli)
