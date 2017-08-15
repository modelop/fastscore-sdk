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
            return(status==204)
        },
        save_schema = function(schema){
            if(is.null(schema$source)){
                stop("FastScoreError: Schema source property not set.")
            }
            status <- .self$swg$schema_put_with_http_info(.self$name,
                schema$name,
                schema$source)[[2]]
            return(status==204)
        },
        save_stream = function(stream){
            if(is.null(stream$desc)){
                stop("FastScoreError: Stream descriptor property not set.")
            }
            status <- .self$swg$stream_put_with_http_info(.self$name,
                stream$name,
                stream$desc)[[2]]
            return(status == 204)
        },
        save_sensor = function(sensor){
            if(is.null(sensor$desc)){
                stop("FastScoreError: Sensor descriptor property not set.")
            }
            status <- .self$swg$sensor_put_with_http_info(.self$name,
                sensor$name,
                sensor$desc
                )
        }

    )
)
