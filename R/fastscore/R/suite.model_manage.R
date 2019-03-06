#' @include suite.instance.R

#' @export ModelManage
ModelManage <- setRefClass("ModelManage",
    contains="InstanceBase",
    fields=list(),
    methods=list(
        model_list = function(){
            return(.self$swg$model_list(.self$name))
        },
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
        },
        model_delete = function(name){
            return(.self$swg$model_delete(.self$name, name))
        },
        schema_list = function(){
            return(.self$swg$schema_list(.self$name))
        },
        schema_get = function(name){
            source <- .self$swg$schema_get(.self$name, name)
            return(Schema$new(name=name, source=source, model_manage=.self))
        },
        schema_delete = function(name){
            return(.self$swg$schema_delete(.self$name, name))
        },
        stream_list = function(){
            return(.self$swg$stream_list(.self$name))
        },
        stream_get = function(name){
            desc <- .self$swg$stream_get(.self$name, name)
            return(Stream$new(name=name, desc=desc, model_manage=.self))
        },
        stream_delete = function(name){
            return(.self$swg$stream_delete(.self$name, name))
        },
        sensor_list = function(){
            return(.self$swg$sensor_list(.self$name))
        },
        sensor_get = function(name){
            desc <- .self$swg$sensor_get(.self$name, name)
            return(Sensor$new(name=name, desc=desc, model_manage=.self))
        },
        sensor_delete = function(name){
            return(.self$swg$sensor_delete(.self$name, name))
        },
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
        },
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
        },
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
        },
        save_sensor = function(sensor){
            if(is.null(sensor$desc)){
                stop("FastScoreError: Sensor descriptor property not set.")
            }
            status <- .self$swg$sensor_put_with_http_info(.self$name,
                sensor$name,
                sensor$desc
                )
        },


        #added functions starts here
        model_load_from_file = function(name, path = "./fastscore/library/models/"){
          if(!file.exists(paste(path, name, sep=""))){
            stop("FastScore Error: model file does not exists in directory (check if extension is included in name).")
          }
          model <- Model(name = name, mtype = guess_mtype(name),
                source = paste(readLines(paste(path, name, sep="")), collapse="\n"),
                model_manage = .self)
          .self$save_model(model)
        },

        schema_load_from_file = function(name, path = "./fastscore/library/schemas/"){
          if(!file.exists(paste(path, name, ".avsc", sep=""))){
            stop("FastScore Error: schema file does not exists in directory. (DO NOT included extension in name)")
          }
          schema <- Schema(name = name,
                         source = fromJSON(file=paste(path, name, ".avsc", sep="")),
                         model_manage = .self)
          .self$save_schema(schema)
        },

        stream_load_from_file = function(name, path = "./fastscore/library/streams/"){
          if(!file.exists(paste(path, name, ".json", sep=""))){
            stop("FastScore Error: stream file does not exists in directory. (DO NOT included extension in name)")
          }
          stream <- Stream(name = name,
                           desc = fromJSON(file=paste(path, name, ".json", sep="")),
                           model_manage = .self)
          .self$save_stream(stream)
        },
        model_add_attachment = function(model_name, attachment_name, attachment_path = "./fastscore/library/attachments/"){
          api.add_attachment(model_name, paste(attachment_path, attachment_name, sep=""))
        }
    )
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
