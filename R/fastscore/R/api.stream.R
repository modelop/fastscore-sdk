#' List the streams in Model Manage.
#' @return A list of stream names.
#' @export
api.list_streams <- function(){
  result <- service.get('model-manage', '/1/stream')
  if(result[[1]] == 200){
    return(result[[2]])
  }
  else{
    stop(result[[2]])
  }
}

#' Add the named stream to Model Manage.
#' @return True if successful.
#' @param stream_name A name for the stream.
#' @param stream_content The stream descriptor.
#' @export
api.add_stream <- function(stream_name, stream_content){
  ctype <- 'application/json'
  result <- service.put('model-manage', paste('/1/stream/', stream_name, sep=''),
              ctype, stream_content)

  if(result[[1]] == 201){
    message(paste('Stream', stream_name, 'added to Model Manage.'))
    return(TRUE)
  } else if(result[[1]] == 204){
    message(paste('Stream', stream_name, 'updated in Model Manage.'))
    return(TRUE)
  }
  else{
    stop(result[[2]])
  }
}

#' Retrieve the stream descriptor for the named stream.
#' @return A string with the stream descriptor for the named stream.
#' @param stream_name The name of the stream to retrieve.
#' @export
api.get_stream <- function(stream_name){
  result <- service.get('model-manage', paste('/1/stream/', stream_name, sep=''))
  if(result[[1]] == 200){
    return(result[[2]])
  }
  else if(result[[1]] == 404){
    message(paste('Stream', stream_name, 'not found in Model Manage.'))
    return(FALSE)
  }
  else{
    stop(result[[2]])
  }
}

#' Remove the named stream from Model Manage.
#' @return True, if successful.
#' @param stream_name The name of the stream to remove.
#' @export
api.remove_stream <- function(stream_name){
  result <- service.delete('model-manage', paste('/1/stream/', stream_name, sep=''))
  if(result[[1]] == 404){
    message(paste('Stream', stream_name, 'not found in Model Manage.'))
    return(FALSE)
  }
  else if(result[[1]] == 204){
    message(paste('Stream', stream_name, 'removed from Model Manage.'))
    return(TRUE)
  }
  else{
    stop(result[[2]])
  }
}
