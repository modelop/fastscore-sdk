# Working on R-SDK built on swagger-codegen generated client ("swagger")

# devtools ======
library(help = "swagger")
# devtools::build_vignettes()

# fastscoRe::Instance$new() =======
api_cli <- fastscoRe::Instance$new(basePath = "https://localhost:8000")

# fastscoRe::Connect$new() ======
con <- fastscoRe::Connect$new(apiClient = api_cli)
  con
  con$health_get(instance = "connect")$response
  resp <- con$health_get(instance = "connect")$response
  httr::content(resp)
  str(resp)
  resp$url

# fastscoRe::ModelManageApi$new(...) =======
modman <- fastscoRe::ModelManage$new(apiClient = api_cli)

  # MODEL ----
  modman$model_put(
    instance = "model-manage-1", model = 'grist',
    source = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/grist.R",
    content_type = 'application/vnd.fastscore.model-r' # GRABBED FROM $model_get
    )
  modman$model_list(instance = "model-manage-1")$content
  modman$model_get(instance = "model-manage-1", model = "surv_tree")$content
  modman$model_delete(instance = "model-manage-1", model = "grist")

  # STREAM ----
  strmlist <- modman$stream_list(instance = "model-manage-1")
    strmlist$content
    strmlist$response
    rm(strmlist)

  strm <- modman$stream_get(instance = "model-manage-1", stream = "demo-1")
    strm$response
    strm$content
    rjson::toJSON(strm$content)
    rm(strm)

  modman$stream_put(
    instance = "model-manage-1", stream = "stream_eg2",
    desc = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/eg_input_stream.jsons",
    httr::content_type('application/json')
    )

  modman$stream_delete(instance = "model-manage-1", stream = "stream_eg2")

  # SCHEMA ----
  schlist <- modman$schema_list(instance = "model-manage-1")
    schlist$content
    schlist$response
    rm(schlist)

  sch <- modman$schema_get(instance = "model-manage-1", schema = "output")
    sch$content
    sch$response
    rjson::toJSON(sch$content)
    cat(rjson::toJSON(sch$content))
    rm(sch)

  modman$schema_put(
    instance = "model-manage-1", schema = "output_eg",
    source = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/output.avsc",
    httr::content_type('application/json')
  )

  modman$schema_delete(instance = "model-manage-1", schema = "output_eg")

  # ATTACHMENT ----
  attchlist <- modman$attachment_list(instance = "model-manage-1", model = "echo-py")
    attchlist$content
    attchlist$response

  modman$attachment_get(
    instance = "model-manage-1", model = "logit", attachment = "model.tar.gz"
    ) # need to add path argument (where to save)

  modman$attachment_put(instance = "model-manage-1",
                        model = "echo-py",                # any model will do
                        attachment = "att_eg2",            # attachment e.g.
                        attachment_file = "model.tar.gz")

  modman$attachment_delete(instance = "model-manage-1",
                           model = "echo-py",
                           attachment = "att_eg")







# EngingeApi$new(...) =========
eng <- fastscoRe::Engine$new(apiClient = api_cli)

  # MODEL ====
  eng$model_load(
    instance = "engine-1",
    data = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/grist.R",
    # dry_run = ,
    content_type = "application/vnd.fastscore.model-r",
    content_disposition = "x-model; name='huzzah!!'"
  )
