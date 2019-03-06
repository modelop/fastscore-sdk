api.list_schemata <- function(){
  result <- service.get('model-manage', '/1/schema')
  if(result[[1]] == 200){
    return(rjson::fromJSON(result[[2]]))
  }
  else{
    stop(result[[2]])
  }
}

api.add_schema <- function(schema_name, schema_content){

  ctype <- 'application/json'
  result <- service.put('model-manage', paste('/1/schema/', schema_name, sep=''),
              ctype, schema_content)

  if(result[[1]] == 201){
    message(paste('Schema', schema_name, 'added to Model Manage.'))
    return(TRUE)
  } else if(result[[1]] == 204){
    message(paste('Schema', schema_name, 'updated in Model Manage.'))
    return(TRUE)
  }
  else{
    stop(result[[2]])
  }
}

api.get_schema <- function(schema_name){

  result <- service.get('model-manage', paste('/1/schema/', schema_name, sep=''))
  if(result[[1]] == 200){
    return(result[[2]])
  }
  else if(result[[1]] == 404){
    message(paste('Schema', schema_name, 'not found in Model Manage.'))
    return(FALSE)
  }
  else{
    stop(result[[2]])
  }
}

api.remove_schema <- function(schema_name){
  result <- service.delete('model-manage', paste('/1/schema/', schema_name, sep=''))
  if(result[[1]] == 404){
    message(paste('Schema', schema_name, 'not found in Model Manage.'))
    return(FALSE)
  }
  else if(result[[1]] == 204){
    message(paste('Schema', schema_name, 'removed from Model Manage.'))
    return(TRUE)
  }
  else{
    stop(result[[2]])
  }
}
