#-- engine object --#
#' @include model.R
setClassUnion("modelOrNull", c("Model", "NULL"))
setClassUnion("characterOrNull", c("character", "NULL"))

Engine.MAX_INLINE_ATTACHMENT <- 1024*1024

#' Engine
#' A class that represents a FastScore Engine
#' @export Engine
Engine <- setRefClass("Engine",
    contains="InstanceBase",
    fields=list(),
    methods=list(
        initialize=function(...){
            callSuper(...)
            .self
        },
        input_set = function(slot, stream){
            if(slot != 1){
                stop("FastScoreError: Only stream slot 1 is currently supported")
            }
            return(.self$swg$input_stream_set(.self$name, stream$desc))
        },
        output_set = function(slot, stream){
            if(slot != 1){
                stop("FastScoreError: Only stream slot 1 is currently supported")
            }
            return(.self$swg$output_stream_set(.self$name, stream$desc))
        },
        load_model = function(model, force_inline=FALSE){

            maybe_externalize <- function(att){
                ctype <- ATTACHMENT_CONTENT_TYPES[[att$atype]]
                # we always externalize attachments, because reading binary in R
                # is annoying.
                # if(att$datasize > Engine.MAX_INLINE_ATTACHMENT && !force_inline){

                    ext_type <- paste('message/external-body; ',
                                      'access-type=x-model-manage; ',
                                      'ref="urn:fastscore:attachment:"',
                                      model$name,
                                      ':',
                                      att$name,
                                      sep='')
                    body <- paste('Content-Type: ',
                                  ctype,
                                  '\r\n',
                                  'Content-Length: ',
                                  att$datasize,
                                  '\r\n\r\n', sep='')
                    return list(att$name, body, ext_type)
                # }
            }

            quirk <- function(name){
                if(name == 'x-model'){
                    return(name)
                }
                else{
                    return('filename')
                }
            }

            multipart_body <- function(parts, boundary){
                noodle <- ''
                for(part in parts){
                    tag <- part[[1]]
                    name <- part[[2]][[1]]
                    body <- part[[2]][[2]]
                    ctype <- part[[2]][[3]]
                    noodle <- paste(noodle,
                        '\r\n--',boundary,'\r\n',
                        'Content-Disposition: ', tag,'; ',
                        quirk(name),'="',name,'"\r\n',
                        'Content-Type: ',ctype,'\r\n',
                        body, sep='')
                }
                noodle <- paste(noodle, '\r\n--', boundary, '--\r\n', sep='')
                return(noodle)
            }

            ct <- MODEL_CONTENT_TYPES[[model$mtype]]
            attachments <- list(model$attachment_list())
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
                parts[[k+1]] <- list('x-model', list(model$name, model$source, ct))
                boundary <- paste(as.hexmode(sample.int(16^2, 12)), collapse='')
                data <- multipart_body(parts, boundary)
                return(.self$swg$model_load(.self$name,
                        data,
                        content_type=paste('multipart/mixed; boundary=', boundary, sep=''))
            }
        },
        unload_model = function(){
            return(.self$swg$job_delete(.self$name))
        },
        scale = function(n){
            return(.self$swg$job_scale(.self$name, n))
        },
        sample_stream = function(stream, n){
            return(.self$swg$stream_sample(.self$name, stream$desc, n=n))
        },
        score = function(data, encode=TRUE){
            job_status <- .self$swg$job_status(.self$name)

            if(!('model' %in% names(job_status)) || is.null(job_status[['model']])){
              stop('FastScoreError: No currently running model')
            }

            input_schema <- jsonNodeToAvroType(job_status[['model']][['input_schema']], fromString=FALSE)
            output_schema <- jsonNodeToAvroType(job_status[['model']][['output_schema']], fromString=FALSE)

            input_list <- data
            if(encode){
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
            input_str <- paste(input_str, '\n', '{"$fastscore":"pig"}\n', sep='')

            .self$swg$job_io_input(.self$name, data=input_str, id=1)

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
        },

        # -- TODO: Move this to RModel

        deploy=function(model){
            # stop all running jobs
            api.stop_job(.self$container)
            # update the model
            .self$model <- model

            # add the model, streams, and schemata to model manage
            api.add_model(model$name, model$to_string(), model_type='R')
            for(attachment in model$attachments){
                api.add_attachment(model$name, attachment)
            }
            api.add_schema(model$options[['input']], avroTypeToJsonNode(model$input_schema))
            api.add_schema(model$options[['output']], avroTypeToJsonNode(model$output_schema))

            input_stream_name <- paste(model$name, '_in', sep='')
            output_stream_name <- paste(model$name, '_out', sep='')
            input_stream_batch <- ''
            output_stream_batch <- ''
            if(!is.null(model$options[['recordsets']])){
                  if(model$options[['recordsets']] == 'input')
                      input_stream_batch  <- ', "Batching":"explicit"'
                  if(model$options[['recordsets']] == 'output')
                      output_stream_batch <- ', "Batching":"explicit"'
                  if(model$options[['recordsets']] == 'both'){
                      input_stream_batch  <- ', "Batching":"explicit"'
                      output_stream_batch <- ', "Batching":"explicit"'
                  }
            }

            input_stream_desc <- paste('{"Schema": {"$ref": "', model$options[['input']], '"}, ',
            '"Envelope": "delimited", "Transport": {"Type": "REST"}, "Encoding": "json"',
            input_stream_batch, '}', sep='')

            output_stream_desc <- paste('{"Schema": {"$ref": "', model$options[['output']], '"}, ',
            '"Envelope": "delimited", "Transport": {"Type": "REST"}, "Encoding": "json"',
            output_stream_batch, '}', sep='')

            api.add_stream(input_stream_name, input_stream_desc)
            api.add_stream(output_stream_name, output_stream_desc)
            # now, run the model
            api.run_job(model$name, input_stream_name, output_stream_name, .self$container)
        },
        stop = function(){
            result <- api.stop_job(.self$container)
            if(result){
                message("Engine stopped.")
            }
            return(result)
        }

    )
)
