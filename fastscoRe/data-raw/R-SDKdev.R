# Working on R-SDK built on swagger-codegen generated client ("swagger")

httr::set_config(httr::config(ssl_verifypeer = FALSE)) # global ignore-self-certify config

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
  # *** MAKE 'instance' a Connect field ***

# fastscoRe::ModelManageApi$new(...) =======
modman <- fastscoRe::ModelManage$new(apiClient = api_cli, instance = 'model-manage-1')

  # MODEL ----
  modman$model_put(
    model = 'c_t_test',
    source = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/grist.R",
    content_type = 'R'
    )

  modman$model_list()$content # + (i.e. 'instance' updated)
  modman$model_get(model = "surv_tree")$content
  modman$model_delete(model = 'W_o_instance')

  # STREAM ----
  strmlist <- modman$stream_list()
    strmlist$content
    strmlist$response
    rm(strmlist)

  strm <- modman$stream_get(stream = "demo-1")
    strm$response
    strm$content
    rjson::toJSON(strm$content)
    rm(strm)

  modman$stream_put(
    stream = "CWC",
    desc = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/eg_input_stream.jsons",
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
  attchlist <- modman$attachment_list(model = "echo-py")
    attchlist$content
    attchlist$response

  modman$attachment_get(model = "logit", attachment = "model.tar.gz") # need to add path argument (where to save)

  modman$attachment_put(model = "echo-py",                 # any model will do
                        attachment = "att_eg2",            # attachment e.g.
                        attachment_file = "model.tar.gz")

  modman$attachment_delete(model = "echo-py",
                           attachment = "att_eg2")


# EngingeApi$new(...) =========
eng <- fastscoRe::Engine$new(apiClient = api_cli)
  # same issues to fix with instance, content_type, content_disposition

  # MODEL ====
  eng$model_load(
    instance = "engine-1",
    data = "/Users/cwcomiskey/Desktop/ODG/R-SDK/SDK_egs/grist.R",
    # dry_run = ,
    content_type = "application/vnd.fastscore.model-r",
    content_disposition = "x-model; name='huzzah!!'"
  )
  # Change so supply engine with 'model object', instance of model class;
  # Model manage should return model objects, etc.
  # Same applies for schema, streams, etc.; give them classes

  #
