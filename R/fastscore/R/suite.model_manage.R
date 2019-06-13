#' @include suite.instance.R

#' @title ModelManage
#' @description A class that represents a FastScore ModelManage
#' @export ModelManage
ModelManage <- setRefClass("ModelManage",
    contains="InstanceBase",
    fields=list(),
    methods=list()
)

#' List all models
#' @name ModelManage_model_list
#' @return a list of model names
NULL
ModelManage$methods(
  model_list = function(){
    return(.self$swg$model_list(.self$name))
  }
)

#' Get a model object
#' @name ModelManage_model_get
#' @param name model name
#' @return corresponding model object
NULL
ModelManage$methods(
  model_get = function(name){
    sh <- .self$swg$model_get_with_http_info(.self$name,name)
    source <- sh[[1]]
    headers <- sh[[3]]
    ct <- headers[['content-type']]
    for(i in 1:length(MODEL_CONTENT_TYPES)){
      mtype <- names(MODEL_CONTENT_TYPES)[[i]]
      ct1 <- MODEL_CONTENT_TYPES[[i]]
      if(ct1 == ct){
        return(Model$new(name=name,
                         mtype=mtype,
                         source=source,
                         model_manage=.self))
      }
    }
    stop(paste("FastScoreError: Unexpected model MIME type:", ct))
  }
)

#' Delete a model
#' @name ModelManage_model_delete
#' @param name model name
#' @return delete corresponding model
NULL
ModelManage$methods(
  model_delete = function(name){
    return(.self$swg$model_delete(.self$name, name))
  }
)

#' List all schemas
#' @name ModelManage_schema_list
#' @return a list of schema names
NULL
ModelManage$methods(
  schema_list = function(){
    return(.self$swg$schema_list(.self$name))
  }
)

#' Get a schema object
#' @name ModelManage_schema_get
#' @param name schema name
#' @return corresponding schema object
NULL
ModelManage$methods(
  schema_get = function(name){
    source <- .self$swg$schema_get(.self$name, name)
    return(Schema$new(name=name, source=source, model_manage=.self))
  }
)

#' Delete a schema
#' @name ModelManage_schema_delete
#' @param name schema name
#' @return delete corresponding schema
NULL
ModelManage$methods(
  schema_delete = function(name){
    return(.self$swg$schema_delete(.self$name, name))
  }
)

#' List all streams
#' @name ModelManage_stream_list
#' @return a list of stream names
NULL
ModelManage$methods(
  stream_list = function(){
    return(.self$swg$stream_list(.self$name))
  }
)

#' Get a stream object
#' @name ModelManage_stream_get
#' @param name stream name
#' @return corresponding stream object
NULL
ModelManage$methods(
  sensor_get = function(name){
    desc <- .self$swg$sensor_get(.self$name, name)
    return(Sensor$new(name=name, desc=desc, model_manage=.self))
  }
)

#' Delete a stream
#' @name ModelManage_stream_delete
#' @param name stream name
#' @return delete corresponding stream
NULL
ModelManage$methods(
  stream_delete = function(name){
    return(.self$swg$stream_delete(.self$name, name))
  }
)

#' List all sensors
#' @name ModelManage_sensor_list
#' @return a list of sensor names
NULL
ModelManage$methods(
  sensor_list = function(){
    return(.self$swg$sensor_list(.self$name))
  }
)

#' Get a sensor object
#' @name ModelManage_sensor_get
#' @param name sensor name
#' @return corresponding sensor object
NULL
ModelManage$methods(
  stream_get = function(name){
    desc <- .self$swg$stream_get(.self$name, name)
    return(Stream$new(name=name, desc=desc, model_manage=.self))
  }
)

#' Delete a sensor
#' @name ModelManage_sensor_delete
#' @param name sensor name
#' @return delete corresponding sensor
NULL
ModelManage$methods(
  sensor_delete = function(name){
    return(.self$swg$sensor_delete(.self$name, name))
  }
)

#' Save a model
#' @name ModelManage_save_model
#' @param model a model object
#' @return actionn result message
NULL
ModelManage$methods(
  save_model = function(model){
    if(is.null(model$source)){
      stop("FastScoreError: Model source property not set.")
    }
    ct <- MODEL_CONTENT_TYPES[[model$mtype]]
    status <- .self$swg$model_put_with_http_info(.self$name,
                                                 model$name,
                                                 model$source,
                                                 content_type=ct)[[2]]
    if(status == 201){
      return("New model loaded into ModelManage.")
    }
    else if(status == 204){
      return("Existing model updated.")
    }
    else{
      return("FastScoreError: Model cannot be saved.")
    }
  }
)

#' Save a schema
#' @name ModelManage_save_schema
#' @param schema a schema object
#' @return actionn result message
NULL
ModelManage$methods(
  save_schema = function(schema){
    if(is.null(schema$source)){
      stop("FastScoreError: Schema source property not set.")
    }
    status <- .self$swg$schema_put_with_http_info(.self$name,
                                                  schema$name,
                                                  schema$source)[[2]]
    if(status == 201){
      return("New schema loaded into ModelManage.")
    }
    else if(status == 204){
      return("Existing schema updated.")
    }
    else{
      return("FastScoreError: Schema cannot be saved.")
    }
  }
)

#' Save a stream
#' @name ModelManage_save_stream
#' @param stream a stream object
#' @return actionn result message
NULL
ModelManage$methods(
  save_stream = function(stream){
    if(is.null(stream$desc)){
      stop("FastScoreError: Stream descriptor property not set.")
    }
    status <- .self$swg$stream_put_with_http_info(.self$name,
                                                  stream$name,
                                                  stream$desc)[[2]]
    if(status == 201){
      return("New stream loaded into ModelManage.")
    }
    else if(status == 204){
      return("Existing stream updated.")
    }
    else{
      return("FastScoreError: Stream cannot be saved.")
    }
  }
)

#' Save a sensor
#' @name ModelManage_save_sensor
#' @param sensor a sensor object
#' @return actionn result message
NULL
ModelManage$methods(
  save_sensor = function(sensor){
    if(is.null(sensor$desc)){
      stop("FastScoreError: Sensor descriptor property not set.")
    }
    status <- .self$swg$sensor_put_with_http_info(.self$name,
                                                  sensor$name,
                                                  sensor$desc
    )
    if(status == 201){
      return("New sensor loaded into ModelManage.")
    }
    else if(status == 204){
      return("Existing sensor updated.")
    }
    else{
      return("FastScoreError: sensor cannot be saved.")
    }
  }
)


# added functions starts here

#' Load a model from local file
#' @name ModelManage_model_load_from_file
#' @param name model name, including file extension for model language
#' @param path path of the model file
#' @return if a model is successfully loaded
NULL
ModelManage$methods(
  model_load_from_file = function(name, path = "./library/models/"){
    if(!file.exists(paste(path, name, sep=""))){
      stop("FastScore Error: model file does not exists in directory (check if extension is included in name).")
    }
    model <- Model(name = name, mtype = guess_mtype(name),
                   source = paste(readLines(paste(path, name, sep="")), collapse="\n"),
                   model_manage = .self)
    return(.self$save_model(model))
  }
)

#' Load a schema from local file
#' @name ModelManage_schema_load_from_file
#' @param name schema name, NOT including file extension, as only supporting .avsc, and to match up with model script smart comment
#' @param path path of the schema file
#' @return if a schema is successfully loaded
NULL
ModelManage$methods(
  schema_load_from_file = function(name, path = "./library/schemas/"){
    if(!file.exists(paste(path, name, ".avsc", sep=""))){
      stop("FastScore Error: schema file does not exists in directory. (DO NOT included extension in name)")
    }
    schema <- Schema(name = name,
                     source = fromJSON(file=paste(path, name, ".avsc", sep="")),
                     model_manage = .self)
    return(.self$save_schema(schema))
  }
)

#' Load a stream from local file
#' @name ModelManage_stream_load_from_file
#' @param name stream name, NOT including file extension, as only supporting .json
#' @param path path of the stream file
#' @return if a stream is successfully loaded
NULL
ModelManage$methods(
  stream_load_from_file = function(name, path = "./library/streams/"){
    if(!file.exists(paste(path, name, ".json", sep=""))){
      stop("FastScore Error: stream file does not exists in directory. (DO NOT included extension in name)")
    }
    stream <- Stream(name = name,
                     desc = fromJSON(file=paste(path, name, ".json", sep="")),
                     model_manage = .self)
    return(.self$save_stream(stream))
  }
)

#' Add an local attachment to a model
#' @name ModelManage_model_add_attachment
#' @param model_name model name
#' @param attachment_name attachment name, including file extensions for attachment type
#' @param attachment_path path of the attachment file
#' @return if an attachment is successfully loaded
NULL
ModelManage$methods(
  model_add_attachment = function(model_name, attachment_name, attachment_path = "./fastscore/library/attachments/"){
    return(api.add_attachment(model_name, paste(attachment_path, attachment_name, sep="")))
  }
)



#need to implement more model types
guess_mtype = function(name){
  ext <- tools::file_ext(name)
  if(ext == 'R'){
    return('R')
  }
  else if(ext=='py'){
    return('python')
  }
  else if(ext=='py3'){
    return('python3')
  }
  else if(ext=='ipynb'){
    return('jupyter')
  }
  else{
    stop(paste('Model', name, 'does not have a known file type.'))
  }
}
