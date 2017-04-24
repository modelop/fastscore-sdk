#' List the streams in Model Manage.
#' @return A list of stream names.
#' @export
api.list_streams <- function(){
  python.exec('import fastscore.api')
  as.list(python.call('fastscore.api.list_streams'))
}

#' Add the named stream to Model Manage.
#' @return True if successful.
#' @param stream_name A name for the stream.
#' @param stream_content The stream descriptor.
#' @export
api.add_stream <- function(stream_name, stream_content){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.add_stream', stream_name, stream_content)
  if(result){
      message(paste("Stream", stream_name, "added to Model Manage."))
  }
  return(result)
}

#' Retrieve the stream descriptor for the named stream.
#' @return A string with the stream descriptor for the named stream.
#' @param stream_name The name of the stream to retrieve.
#' @export
api.get_stream <- function(stream_name){
  python.exec('import fastscore.api')
  return(python.call('fastscore.api.get_stream', stream_name))
}

#' Remove the named stream from Model Manage.
#' @return True, if successful.
#' @param stream_name The name of the stream to remove.
#' @export
api.remove_stream <- function(stream_name){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.remove_stream', stream_name)
  if(result){
      message(paste("Stream", stream_name, "removed from Model Manage."))
  }
  return(result)
}
