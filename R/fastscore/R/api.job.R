#' Runs the named model using the specified input and output streams.
#' @return True, if successful.
#' @param model The name of the model in Model Manage.
#' @param input_stream The name of the input stream descriptor.
#' @param output_stream The name of the output stream descriptor.
#' @param container The name of the container to use (optional)
#' @export
api.run_job <- function(model, input_stream, output_stream, container=NULL){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.run_job', model, input_stream,
                        output_stream, container)
  if(result){
      message('Engine is ready to score.')
  }
  return(result)
}

#' Deploys the named model.
#' @return True, if successful.
#' @param model_content The contents of the model.
#' @param model_name A name for the model.
#' @param ctype The content-type disposition for the model.
#' @param container The name of the container to use (optional)
#' @export
api.deploy_model <- function(model_content, model_name, ctype, container=NULL){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.deploy_model', model_content,
            model_name, ctype, container)
  if(result){
      message('Model deployed to engine.')
  }
  return(result)
}

#' Deploys the named stream to the engine (input).
#' @return True, if successful.
#' @param stream_content A stream descriptor string.
#' @param stream_name A name for this stream.
#' @param container The name of the container to use (optional)
#' @export
api.deploy_input_stream <- function(stream_content, stream_name, container=NULL){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.deploy_input_stream', stream_content,
            stream_name, container)
  if(result){
      message('Input stream set.')
  }
  return(result)
}

#' Deploys the named stream to the engine (output).
#' @return True, if successful.
#' @param stream_content A stream descriptor string.
#' @param stream_name A name for this stream.
#' @param container The name of the container to use (optional)
#' @export
api.deploy_output_stream <- function(stream_content, stream_name, container=NULL){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.deploy_output_stream', stream_content,
            stream_name, container)
  if(result){
      message('Output stream set.')
  }
  return(result)
}

#' Send inputs to the engine for scoring, and return the results.
#' @param input_data The data to send to the engine for scoring (an array of JSON strings)
#' @param container The name of the container to use (optional)
#' @return A list of output records (JSON strings).
#' @export
api.job_input <- function(input_data, container=NULL){
  python.exec('import fastscore.api')
  as.list(python.call('fastscore.api.job_input', input_data, container))
}

#' Stop the current job.
#' @return True if successful.
#' @param container The name of the container to use (optional)
#' @export
api.stop_job <- function(container=NULL){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.stop_job', container)
  return(result)
}
