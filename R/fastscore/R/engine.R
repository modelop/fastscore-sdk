#-- engine object --#
#' @include model.R
setClassUnion("modelOrNull", c("Model", "NULL"))
setClassUnion("characterOrNull", c("character", "NULL"))
#' Engine
#' A class that represents a FastScore Engine
#' @export Engine
Engine <- setRefClass("Engine",
    fields=list(
        proxy_prefix="character",
        model="modelOrNull",
        container="characterOrNull"
    ),
    methods=list(
        initialize=function(..., proxy_prefix){
            callSuper(...)
            api.connect(proxy_prefix)
            .self$proxy_prefix <- proxy_prefix
            .self
        },
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
        },
        score = function(data, use_json=FALSE){
            job_status <- api.job_status(.self$container)
            if(!('model' %in% names(job_status)) || is.null(job_status[['model']])){
              stop('No currently running model')
            }

            input_schema <- jsonNodeToAvroType(job_status[['model']][['input_schema']], fromString=FALSE)
            output_schema <- jsonNodeToAvroType(job_status[['model']][['output_schema']], fromString=FALSE)

            input_list <- data
            if(!use_json){
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
            outputs <- api.job_input(input_list, .self$container)
            if(use_json){
                return(outputs)
            }
            else{
                lastitem <- RJSONIO::fromJSON(outputs[[length(outputs)]])
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
)
