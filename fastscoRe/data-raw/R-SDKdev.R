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
  con
  con$health_get(instance = "connect")$response
  resp <- con$health_get(instance = "connect")$response
  httr::content(resp)
  str(resp)
  resp$url

# ModelManageApi$new(...) =======
modman <- fastscoRe::ModelManage$new(apiClient = api_cli)

  # MODEL
  modman$model_delete(instance = "model-manage-1", model = "test")
  modman$model_list(instance = "model-manage-1")$content
  modman$model_get(instance = "model-manage-1", model = "surv_tree")
  modman$model_put(
    instance = "model-manage-1", model = 'grist',
    source = "/Users/cwcomiskey/Desktop/grist.R",
    content_type = 'application/vnd.fastscore.model-r' # GRABBED FROM $model_get
    )

  # STREAM
  strmlist <- modman$stream_list(instance = "model-manage-1")
    strmlist$content
    strmlist$response

  strm <- modman$stream_get(instance = "model-manage-1", stream = "demo-1")
    strm$response
    strm$content
    rjson::toJSON(strm$content)

  modman$stream_put(
    instance = "model-manage-1", stream = "stream_eg2",
    desc = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/eg_input_stream.jsons",
    httr::content_type('application/json')
    )






  # SCHEMA


  # ATTACHMENT



# EngingeApi$new(...) =========
eng <- swagger::EngineApi$new(apiClient = api_cli)
