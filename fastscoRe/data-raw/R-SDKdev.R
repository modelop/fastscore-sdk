# Working on R-SDK built on swagger-codegen generated client ("swagger")

httr::set_config(httr::config(ssl_verifypeer = FALSE))

# devtools ======
library(help = "swagger")
# devtools::build_vignettes()

# fastscoRe::Instance$new() =======
api_cli <- fastscoRe::Instance$new(basePath = "https://localhost:8000")
# FastScore Asset Classes =====
  # MODEL =====
  m_ob <- Model$new(
    name = 'model1',
    mtype = 'R',
    source = "../../SDK_egs/grist.R",
    model_manage = NA
    )

  # STREAM ====
  str_ob <- Stream$new(
    name = 'stream1',
    source = '../../SDK_egs/eg_input_stream.jsons',
    model_manage = NA
    )

  # SCHEMA ====
  sch_ob <- Schema$new(
    name = 'schema1',
    source = "../../SDK_egs/eg_input_stream.jsons",
    model_manage = NA
  )

# fastscoRe::Connect class ======
con <- fastscoRe::Connect$new(apiClient = api_cli)
  con
  con$health_get(instance = "connect")$response
  resp <- con$health_get(instance = "connect")$response
  httr::content(resp)
  str(resp)
  resp$url
  # *** MAKE 'instance' a Connect field ***

# fastscoRe::ModelManageApi class =======
modman <- fastscoRe::ModelManage$new(apiClient = api_cli, instance = 'model-manage-1')

  # MODEL ----
  modman$model_put(model = m_ob) # * R object name != FS model name
  modman$model_list()$content
  modman$model_get(model = "surv_tree")$content
  modman$model_delete(model = 'model1')

  # STREAM ----
  modman$stream_list()$content

  strm <- modman$stream_get(stream = "demo-1")
    strm$response
    strm$content
    rjson::toJSON(strm$content)
    rm(strm)

  modman$stream_put(
    stream = "CWC",
    desc = "../../SDK_egs/eg_input_stream.jsons",
    httr::content_type('application/json')
    )

  modman$stream_delete(stream = "CWC")

  # SCHEMA ----
  schlist <- modman$schema_list()
    schlist$content
    schlist$response
    rm(schlist)

  sch <- modman$schema_get(schema = "output")
    sch$content
    sch$response
    rjson::toJSON(sch$content)
    cat(rjson::toJSON(sch$content))
    rm(sch)

  modman$schema_put(
    schema = "output_eg",
    source = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/output.avsc",
    httr::content_type('application/json')
  )

  modman$schema_delete(schema = "output_eg")

  # ATTACHMENT ----
  attchlist <- modman$attachment_list(model = "model_attach")
    attchlist$content
    attchlist$response

  modman$attachment_get(model = "logit", attachment = "model.tar.gz") # need to add path argument (where to save)

  modman$attachment_put(model = "model_attach",            # any model will do
                        attachment = "att_eg2",            # attachment e.g.
                        attachment_file = "model.tar.gz")

  modman$attachment_delete(model = "echo-py",
                           attachment = "att_eg2")


# fastscoRe::EngingeApi class =========
eng <- fastscoRe::Engine$new(apiClient = api_cli, instance = 'engine-1')

  # MODEL ====
  eng$model_load(
    data = "../../SDK_egs/grist.R",
    content_type = "R",
    content_disposition = "x-model; name='c_t_test!!'"
  )




