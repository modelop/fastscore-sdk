#-- engine object --#
#' @include suite.instance.R
#' @include model.R
setClassUnion("modelOrNull", c("Model", "NULL"))
setClassUnion("characterOrNull", c("character", "NULL"))

Engine.MAX_INLINE_ATTACHMENT <- 1024*1024

#' @title Engine
#' @description A class that represents a FastScore Engine
#' @export Engine
Engine <- setRefClass("Engine",
    contains="InstanceBase",
    fields=list(),
    methods=list(
        initialize=function(...){
            callSuper(...)
            .self
        },
        scale = function(n){
            return(.self$swg$job_scale(.self$name, n))
        },
        sample_stream = function(stream, n){
            return(.self$swg$stream_sample(.self$name, stream$desc, n=n))
        },

        #added functions starts here

        #when all the files are saved in /library/* corresponding directories
        #attachment_list of attachment names
        #input/output_list are lists consisting of streams and slots
        run_in_library = function(modalmanage, model_name, attachment_list = list(), input_list, output_list){
          #load all schemas in first lines of model
          in_out_total <- length(input_list) + length(output_list)
          model_lines <- readLines(paste("./library/models/", model_name, sep=""), n = in_out_total)
          model_schema <- list()
          for(i in 1:in_out_total){
            model_schema[i] <- strsplit(model_lines[i], ": ")[[1]][2]
          }
          for(x in model_schema){
            message(paste(x, ": ", modalmanage$schema_load_from_file(x), sep=""))
          }
          #load all streams
          for(x in input_list){
            message(paste(x[[1]], ": ", modalmanage$stream_load_from_file(x[[1]]), sep=""))
          }
          for(x in output_list){
            message(paste(x[[1]], ": ", modalmanage$stream_load_from_file(x[[1]]), sep=""))
          }
          #load model
          modalmanage$model_load_from_file(model_name)
          #include all attachments
          if(length(attachment_list) == 0){
            attachment_list <- modalmanage$model_get(model_name)$attachment_list()
          }
          for(x in attachment_list){
            modalmanage$model_add_attachment(model_name, x)
          }
          #set all streams
          for(x in input_list){
            message(paste(x[[1]], " attach: ", .self$input_set(slot=x[[2]], mm$stream_get(x[[1]])), sep=""))
          }
          for(x in output_list){
            message(paste(x[[1]], " attach: ", .self$output_set(slot=x[[2]], mm$stream_get(x[[1]])), sep=""))
          }
          #set model
          message(paste(model_name, " attach: ", .self$load_model(modalmanage$model_get(model_name)), sep=""))
          message(paste("Engine health: ", .self$check_health(), sep=""))
        }
    )
)


#' Attaching input stream to an engine
#' @name Engine_input_set
#' @param slot attaching slot, use even numbers
#' @param stream stream instance to be attached
#' @return if stream is successfully attached
NULL
Engine$methods(
  input_set = function(slot = 0, stream){
    if((slot %% 2) != 0){
      stop("FastScore Error: Input stream only set to even slots.")
    }
    if(slot == 0){
      return(.self$swg$input_stream_set(.self$name, stream$desc))
    }
    else{
      prefix <- proxy_prefix()
      r <- PUT(paste(prefix, .self$name, "/2/active/stream/", slot, sep=""),
               add_headers('Content-Type'='application/json'),
               body=toJSON(stream$desc))
      return(status_code(r) == 204)
    }
  }
)

#' Attaching output stream to an engine
#' @name Engine_output_set
#' @param slot attaching slot, use odd numbers
#' @param stream stream instance to be attached
#' @return if stream is successfully attached
NULL
Engine$methods(
  output_set = function(slot = 1, stream){
    if((slot %% 2) == 0){
      stop("FastScore Error: Input stream only set to odd slots.")
    }
    if(slot == 1){
      return(.self$swg$output_stream_set(.self$name, stream$desc))
    }
    else{
      prefix <- proxy_prefix()
      r <- PUT(paste(prefix, .self$name, "/2/active/stream/", slot, sep=""),
               add_headers('Content-Type'='application/json'),
               body=toJSON(stream$desc))
      return(status_code(r) == 204)
    }
  }
)

#' Load a model to an engine
#' @name Engine_load_model
#' @param model model instance to be attached
#' @param force_inline if bypass preferred list, default = FALSE
#' @return if model is successfully loaded
NULL
Engine$methods(
  load_model = function(model, force_inline=FALSE){

    maybe_externalize <- function(att){
      ctype <- ATTACHMENT_CONTENT_TYPES[[att$atype]]
      # we always externalize attachments, because reading binary in R is annoying.
      # if(att$datasize > Engine.MAX_INLINE_ATTACHMENT && !force_inline){

      ext_type <- paste('message/external-body; ',
                        'access-type="x-model-manage"; ',
                        'ref="urn:fastscore:attachment:',
                        model$name,
                        ':',
                        att$name,
                        '"',
                        sep='')
      body <- paste('Content-Type: ', ctype, '\r\n\r\n', sep='')
      return(list(att$name, body, ext_type))
      # }
    }

    quirk <- function(name){
      if(name == 'x-model'){
        return('name')
      }
      else{
        return('filename')
      }
    }

    multipart_body <- function(parts, boundary){
      noodle <- ''
      for(part in parts){
        tag <- part[[1]]
        body_name <- part[[2]][[1]]
        body <- part[[2]][[2]]
        ctype <- part[[2]][[3]]
        noodle <- paste(noodle,
                        '\r\n--',boundary,'\r\n',
                        'Content-Type: ',ctype,'\r\n\r\n',
                        'Content-Disposition: ', tag,'; ',
                        quirk(tag),'="',body_name,'"\r\n',
                        body,
                        sep='')
      }
      return(noodle)
    }

    ct <- MODEL_CONTENT_TYPES[[model$mtype]]
    attachments <- list()
    l <- 0
    for(name in model$attachment_list()){
      l <- l + 1
      attachments[[l]] <- Attachement(name=name,
                                      model=model,
                                      atype=model$attachment_get(name)[[1]],
                                      datafilepath="",
                                      datasize=model$attachment_get(name)[[2]]
      )
    }

    if(length(attachments) == 0){
      data <- model$source
      cd = paste('x-model; name="', model$name, '"', sep='')
      .self$swg$model_load(.self$name, data, content_type=ct, content_disposition=cd)
    }
    else{
      k <- 1
      parts <- list()
      for(x in attachments){
        parts[[k]] <- list('attachment', maybe_externalize(x))
        k <- k + 1
      }
      boundary <- paste(as.hexmode(sample.int(16^2, 12)), collapse='')
      data <- multipart_body(parts, boundary)
      data <- paste(data, '\r\n--',boundary,'\r\n',
                    'Content-Type: ',ct,'\r\n',
                    'Content-Disposition: x-model; name="', model$name, '"\r\n\r\n',
                    model$source, '\r\n--',boundary,'--\r\n',
                    sep='')
      return(.self$swg$model_load(.self$name,
                                  data,
                                  content_type=paste('multipart/mixed; boundary=', boundary, sep='')))
    }
  }
)

#' Run an input to an engine with loaded model, and get output
#' @name Engine_score
#' @param data input data, which is passed in as a json string
#' @param encode default FALSE. TODO: implement auto-encoding according to model schema
#' @return model output
NULL
Engine$methods(
  score = function(data, encode=FALSE){
    job_status <- .self$swg$job_status(.self$name)

    if(!('model' %in% names(job_status)) || is.null(job_status[['model']])){
      stop('FastScoreError: No currently running model')
    }

    if(length(job_status[['model']][['slots']]) > 2){
      stop('FastScoreError: Only support single input and output slots')
    }

    input_list <- data
    if(encode){
      input_schema <- jsonNodeToAvroType(job_status[['model']][['slots']][[1]][["schema"]], fromString=FALSE)
      output_schema <- jsonNodeToAvroType(job_status[['model']][['slots']][[2]][["schema"]], fromString=FALSE)

      recordset_input <- FALSE
      recordset_output <- FALSE
      if(!is.null(job_status[['model']][['recordsets']]))
      {
        if(job_status[['model']][['recordsets']] == 'input')
          recordset_input <- TRUE
        else if(job_status[['model']][['recordsets']] == 'output')
          recordset_output <- TRUE
        else if(job_status[['model']][['recordsets']] == 'both'){
          recordset_input <- TRUE
          recordset_output <- TRUE
        }
      }
      if(recordset_input){
        input_list <- recordset_to_json(input_list, schema=input_schema)
        input_list[[length(input_list)+1]] <- '{"$fastscore":"set"}'
      }
      else
        input_list <- lapply(input_list, to_json, schema=input_schema)
    }

    input_str <- paste(input_list, collapse='\n')
    #input_str <- paste(input_str, '\n', '{"$fastscore":"pig"}\n', sep='')

    .self$swg$job_io_input(.self$name, data=input_str, id=0)

    output <- .self$swg$job_io_output(.self$name, id=1)

    outputs <- strsplit(output, '\n')[[1]]

    if(!encode){
      outputs <- outputs[nchar(outputs) > 0]
      return(outputs)
    }
    else{
      outputs <- outputs[nchar(outputs) > 0]
      lastitem <- rjson::fromJSON(outputs[[length(outputs)]])
      if('$fastscore' %in% names(lastitem) && lastitem[['$fastscore']] == 'pig'){
        outputs <- outputs[1:(length(outputs)-1)]
      }
      if('$fastscore' %in% names(lastitem) && lastitem[['$fastscore']] == 'set'){
        outputs <- outputs[1:(length(outputs)-1)]
      }
      if(!is.null(job_status[['model']][['recordsets']])){
        if(job_status[['model']][['recordsets']] == 'output' ||
           job_status[['model']][['recordsets']] == 'both'){
          return(recordset_from_json(outputs, output_schema))
        }
      }
      return(lapply(outputs, from_json, schema=output_schema))
    }
  }
)

#' Unload all models from an engine, i.e. reset the engine
#' @name Engine_unload_model
#' @return if engine is successfully unloaded
NULL
Engine$methods(
  unload_model = function(){
    return(.self$swg$job_delete(.self$name))
  }
)
