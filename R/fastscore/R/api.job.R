#' Runs the named model using the specified input and output streams.
#' @return True, if successful.
#' @param model The name of the model in Model Manage.
#' @param input_stream The name of the input stream descriptor.
#' @param output_stream The name of the output stream descriptor.
#' @param container The name of the container to use (optional)
#' @export
api.run_job <- function(model, input_stream, output_stream, container=NULL){
  input_desc <- api.get_stream(input_stream)
  output_desc <- api.get_stream(output_stream)
  model_and_ctype <- api.get_model(model, include_ctype=TRUE)
  model_desc <- model_and_ctype[[1]]
  ctype <- model_and_ctype[[2]]
  attachments <- list()
  attachments <- api.list_attachments(model)
  attachments <- lapply(attachments, get_att, model_name=model)
  output_set <- api.deploy_output_stream(output_desc, output_stream, container)
  input_set <- api.deploy_input_stream(input_desc, input_stream, container)
  model_set <- api.deploy_model(model_desc, model, ctype, attachments, container)
  if(output_set && input_set && model_set){
    message('Engine is ready to score.')
  }
  return(output_set && input_set && model_set)
}

#' Deploys the named model.
#' @return True, if successful.
#' @param model_content The contents of the model.
#' @param model_name A name for the model.
#' @param ctype The content-type disposition for the model.
#' @param container The name of the container to use (optional)
#' @export
api.deploy_model <- function(model_content, model_name, ctype, attachments = list(), container=NULL){
  preferred = list()
  if(!is.null(container)){
    preferred[[service.engine_api_name()]] <- container
  }

  parts <- attachments
  parts[[length(parts) + 1]] <- list('name'=model_name,
                                    'body'=model_content,
                                    'content-type'=ctype,
                                    'content-disposition'=paste('x-model; name="', model_name, '"', sep=''))

  result <- service.put_multi(service.engine_api_name(),
                              '/1/job/model',
                              parts,
                              preferred=preferred)

  code <- result[[1]]
  if(code != 204){
    stop(paste('Error setting model:', result[[2]]))
  }
  else{
    message('Model deployed to engine.')
    return(TRUE)
  }
}

#' Deploys the named stream to the engine (input).
#' @return True, if successful.
#' @param stream_content A stream descriptor string.
#' @param stream_name A name for this stream.
#' @param container The name of the container to use (optional)
#' @export
api.deploy_input_stream <- function(stream_content, stream_name, container=NULL){
  preferred = list()
  if(!is.null(container)){
    preferred[[service.engine_api_name()]] <- container
  }
  headers_in <- c('content-type'='application/json',
                  'content-disposition'=paste('x-stream; name=', stream_name, '"', sep=''))
  result <- service.put_with_headers(service.engine_api_name(),
                  '/1/job/stream/in',
                  headers_in,
                  stream_content,
                  preferred=preferred)
  if(result[[1]] != 204){
    stop(paste('Error setting input stream:', result[[2]]))
  }
  else{
    message('Input stream set.')
    return(TRUE)
  }
}

#' Deploys the named stream to the engine (output).
#' @return True, if successful.
#' @param stream_content A stream descriptor string.
#' @param stream_name A name for this stream.
#' @param container The name of the container to use (optional)
#' @export
api.deploy_output_stream <- function(stream_content, stream_name, container=NULL){
  preferred = list()
  if(!is.null(container)){
    preferred[[service.engine_api_name()]] <- container
  }
  headers_out <- c('content-type'='application/json',
                  'content-disposition'=paste('x-stream; name=', stream_name, '"', sep=''))
  result <- service.put_with_headers(service.engine_api_name(),
                  '/1/job/stream/out',
                  headers_out,
                  stream_content,
                  preferred=preferred)
  if(result[[1]] != 204){
    stop(paste('Error setting output stream:', result[[2]]))
  }
  else{
    message('Output stream set.')
    return(TRUE)
  }
}

#' Send inputs to the engine for scoring, and return the results.
#' @param input_data The data to send to the engine for scoring (an array of JSON strings)
#' @param container The name of the container to use (optional)
#' @return A list of output records (JSON strings).
#' @export
api.job_input <- function(input_data, container=NULL){
  preferred = list()
  if(!is.null(container)){
    preferred[[service.engine_api_name()]] <- container
  }
  pig <- '{"$fastscore":"pig"}'
  data <- paste(input_data, collapse='\n')
  data <- paste(data, '\n', pig, '\n', sep='')

  result <- service.post(service.engine_api_name(), '/1/job/input', data=data,
                         preferred=preferred)
  if(result[[1]] != 204){
    stop(result[[2]])
  }
  chip = ''
  pig_received <- FALSE
  outputs <- list()
  while(!pig_received){
    result <- service.get(service.engine_api_name(), '/1/job/output', preferred=preferred)
    if(result[[1]] != 200){
      stop(result[[2]])
    }
    chunk <- paste(chip, result[[2]], sep='')
    while(TRUE){
      x <- regmatches(chunk, regexpr("\n", chunk), invert = TRUE)[[1]]
      if(length(x) > 1){
        rec <- x[[1]]
        chunk <- x[[2]]
        if(rec == pig){
          pig_received <- TRUE
          break
        }
        else if(nchar(rec) > 0){
          outputs[[length(outputs) + 1]] <- rec
        }
      }
      else{
        chip <- x[[1]]
        if(chip == pig){
          pig_received <- TRUE
        }
        break
      }
    }
  }
  return(outputs)
}

#' Stop the current job.
#' @return True if successful.
#' @param container The name of the container to use (optional)
#' @export
api.stop_job <- function(container=NULL){
  preferred = list()
  if(!is.null(container)){
    preferred[[service.engine_api_name()]] <- container
  }
  result <- service.delete(service.engine_api_name(), '/1/job', preferred=preferred)
  if(result[[1]] != 204){
    stop(result[[2]])
  }
  return(TRUE)
}

#' Retrieve the status of the currently running job on the specified engine.
#' @return A JSON object whose top-level fields are 'jets', 'model', 'input',
#'         and 'output'
#' @param container The name of the container to use (optional)
#' @export
api.job_status <- function(container=NULL){
  preferred = list()
  if(!is.null(container)){
    preferred[[service.engine_api_name()]] <- container
  }
  result <- service.get(service.engine_api_name(), '/1/job/status', preferred=preferred)
  if(result[[1]] == 200){
    return(rjson::fromJSON(result[[2]]))
  }
  else{
    stop(result[[2]])
  }
}

#' @export
get_att <- function(model_name, att_name){
  result <- service.head('model-manage', paste('/1/model/', model_name, '/attachment/', att_name, sep=''))
  if(result[[1]] != 200){
    stop('Unable to retrieve attachment.')
  }
  headers <- result[[2]]
  ctype <- headers[['content-type']]
  size <- as.integer(headers[['content-length']])
  ext_type <- paste('message/external-body; ',
                    'access-type=x-model-manage; ',
                    'ref="urn:fastscore:attachment:',
                    model_name,
                    ':',
                    att_name,
                    '"', sep='')
  body <- paste('Content-Type: ', ctype, '\r\n',
                'Content-Disposition: attachment; filename="', att_name, '"\r\n',
                'Content-Length: ', as.character(size), '\r\n', sep='')
  return(list('name'=att_name, 'body'=body, 'content-type'=ext_type))
}
