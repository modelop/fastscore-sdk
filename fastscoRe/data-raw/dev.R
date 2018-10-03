# Scratch

httr::set_config(httr::config(ssl_verifypeer = FALSE)) # global ignore-self-certify config
devtools::document()


# 3: FastScoreError$new() ======
fse <- FastScoreError$new(message = "Unable to retrieve active sensors", 
                          caused_by = "This was caused by something.")
fse$error_string()
FastScoreError$new(message = "Unable to retrieve active sensors", 
                   caused_by = "This was caused by something.")$error_string()

# 4: InstanceBase$new()$active_sensors() =======

x <- InstanceBase$new(name = "Betsy")
InstanceBase$new(name = "Betsy")$active_sensors()
x$active_sensors()

# 5:  $tapping_points() =======
x <- InstanceBase$new(name = "Besty")
x$tapping_points()
InstanceBase$new(
  
)$tapping_points()


# 6:  $install_sensor() ====
b <- InstanceBase$new(name = "Betsy")
name
b$name
# 6.1: InstanceBase$new ========
# api_cli <- InstanceBase$new(name = "FS") # don't need this; see 7

# 7: Connect$new() =====
#     Proxy prefix = https://localhost:15080
#     Base path = api/1/service

httr::set_config(httr::config(ssl_verifypeer = FALSE))

con <- fastscore::Connect$new(proxy_prefix = "https://localhost:15080")

  A <- parse_url(con$apiClient$basePath) # [1] "https://localhost/api/1/service"
  B <- parse_url(con$proxy_prefix) # [1] "https://localhost:15080"
  A$port <- B$port
  con$apiClient$basePath <- build_url(A)
  
  health <- con$health_get(instance = "connect")




# 8: Client API + Connect API ======

# Client API
api_cli <- InstanceBase$new() # Option 1
# api_cli <- InstanceBase$new(basePath = "https://localhost:15080/api/1/service") # Option 2
  
# Connect API
con <- fastscore::Connect$new(apiClient = api_cli, proxy_prefix = "https://localhost:15080") 
  # Use previously instantiated client API
# con <- fastscore::Connect$new(proxy_prefix = "https://localhost:15080") 
  # No previously instantiated client API
  
# Dev: InstanceBase$new() ======
InstanceBase$new(basePath = "http://crap") # TODO: NEED THIS TO THROW FS ERROR

api <- fastscore::InstanceBase$new(basePath = "https://localhost:15080")

# Dev: Connect$new() =====
con <- fastscore::Connect$new(apiClient = api)
  con$basePath 
  con_get <- con$connect_get(instance = "connect")
  con_get <- con$fleet(instance = "connect")

# Dev: ModelManage$new() =======
api <- fastscore::InstanceBase$new(basePath = "https://localhost:15080")
con <- fastscore::Connect$new(apiClient = api)
mod_man <- fastscore::ModelManage$new(apiClient = api)  
  
# Dev: model -- list/get/create/add/delete  =====
  mod_man$model_list(instance = "model-manage-1")$content 
  
  hw_mod <- mod_man$model_get(instance = "model-manage-1", model = "hello-world") # get 'hello-world' model
    hw_mod
    hw_mod$response
    http_type(hw_mod$response) # [1] "application/vnd.fastscore.model-python"
    hw_mod$response$headers$`content-type` # same
    hw_mod$content
    cat(hw_mod$content) # 'hello-world' model
    
# Create fastscore model string
my_mod_string <- "
# fastscore.input: my_mod_input
# fastscore.output: my_mod_output

fs_mod_fun <- function(x){x + 1}
"

# cat(my_mod_string)

my_mod <- Model$new(
  name = "my_mod",
  mtype = 'r',
  source = my_mod_string,
  model_manage = mod_man
)

m_put <- mod_man$model_put(instance = "model-manage-1", 
                   model = "new_model", 
                   source = my_mod$source,
                   content_type = 'application/vnd.fastscore.model-r')    

mod_man$model_delete(instance = "model-manage-1",
                     model = "new_model") # success!!


    
# Dev: schemas -- get/list  ======
  mod_man$schema_list(instance = "model-manage-1")$content
    gbm_sch <- mod_man$schema_get(instance = "model-manage-1", schema = "gbm_input")
      gbm_sch$response
      gbm_sch$content
  
# Dev: schemas -- create/add/delete  ========
api <- fastscore::InstanceBase$new(basePath = "https://localhost:15080")
con <- fastscore::Connect$new(apiClient = api)
mod_man <- fastscore::ModelManage$new(apiClient = api)  

# devtools::install_github("RevolutionAnalytics/ravro/pkg/ravro")

d <- data.frame(x = c(1,2,3), y = c(4, 5, 6))
d <- ravro::avro_make_schema(d, name = "my_schema")

new_schema <- Schema$new(name = "my_schema", 
   model_manage = mod_man,
   source = d
   )

# str(new_schema$source)
# cat(toJSON(new_schema$source))

mod_man$schema_put(instance = "model-manage-1", 
                   schema = "new_schema", 
                   source = d,
                   content_type('application/json'))

# mod_man$schema_list(instance = "model-manage-1")$content

mod_man$schema_delete(instance = "model-manage-1",
                      schema = "new_schema") # NULL = successfully deleted

# mod_man$schema_list(instance = "model-manage-1")$content

# Dev: streams -- list/get/create/add/delete ======
mod_man$stream_list(instance = "model-manage-1") 

fs_stream <- mod_man$stream_get(instance = "model-manage-1", stream = "rest-in")
fs_stream$content
unlist(fs_stream$content, recursive = FALSE)

my_stream <- list("Encoding" =  "json", 
  "Envelope" = NULL, 
  "Transport" = list("Type" = "REST"), 
  "Schema" = list("ref" = "my_model_input"))

my_str <- Stream$new(name = "my_stream",
                     model_manage = "mod_man",
                     source = my_stream)

mod_man$stream_put(instance = "model-manage-1", 
                   stream = "my_stream",
                   desc = my_stream, # descriptor = body = source
                   content_type('application/json'))

# mod_man$stream_list(instance = "model-manage-1") 

mod_man$stream_delete(instance = "model-manage-1", 
                      stream = "my_stream")

# mod_man$stream_list(instance = "model-manage-1") 



# Dev: sensors -- list/get/create/add/delete ======
my_sensor <- list("Tap" = "sys.memory",
                    "Activate" = list("Type" = "regular", "Interval" = 0.5),
                    "Report" = list("Interval" = 3.0),
                    "Filter" = list("Type" = ">=", "Threshold" = "1G")
                  )

my_sen <- Sensor$new(name = "my_sensor",
                     model_manage = "mod_man",
                     source = my_sensor)

mod_man$sensor_put(instance = "model-manage-1",
                   sensor = my_sen$name,
                   desc = my_sen$source,
                   content_type('application/json')
                   )


mod_man$sensor_list(instance = "model-manage-1")$content

sen <- mod_man$sensor_get(instance = "model-manage-1", sensor = "my_sensor")
unlist(sen$content, recursive = FALSE)

mod_man$sensor_delete(instance = "model-manage-1", sensor = "my_sensor")

# Dev: Engine$new() ======
api <- fastscore::InstanceBase$new(basePath = "https://localhost:15080")
con <- fastscore::Connect$new(apiClient = api)
mod_man <- fastscore::ModelManage$new(apiClient = api)
  # mod_man$model_list(instance = "model-manage-1")
eng <- fastscore::Engine$new(apiClient = api)
  # eng[["apiClient"]][["basePath"]]

# Get model ==== #
gbm <- mod_man$model_get(instance = "model-manage-1", model = "auto_gbm")
  # gbm$response
  # cat(gbm$content)
  # gbm$path
  
# load/unload model ==== #
cd = paste('x-model; name="', "auto_gbm", '"', sep='') 
  eng$model_load(instance = "engine-1", data = gbm[["content"]],
                 content_type = 'application/vnd.fastscore.model-python',
                 content_disposition = cd)

  eng$model_unload(instance = "engine-1")

# Load model
eng$model_load(instance = "engine-1", data = ag, 
               content_type = 'application/vnd.fastscore.model-python')

  