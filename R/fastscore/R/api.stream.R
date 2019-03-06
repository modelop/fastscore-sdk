api.list_streams <- function(){
  result <- service.get('model-manage', '/1/stream')
  if(result[[1]] == 200){
    return(rjson::fromJSON(result[[2]]))
  }
  else{
    stop(result[[2]])
  }
}

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
