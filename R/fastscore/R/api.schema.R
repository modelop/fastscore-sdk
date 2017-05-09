#' List all of the schemata in Model Manage, by name.
#' @return A list of the names of every schema in Model Manage.
#' @export
api.list_schemata <- function(){
  result <- service.get('model-manage', '/1/schema')
  if(result[[1]] == 200){
    return(rjson::fromJSON(result[[2]]))
  }
  else{
    stop(result[[2]])
  }
}

#' Add a schema to Model Manage.
#' @return True if successful.
#' @param schema_name The name of the schema in Model Manage
#' @param schema_content The Avro schema (a JSON string)
#' @export
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

#' Retrieve a schema from Model Manage.
#' @return The contents of the named schema (a JSON string)
#' @param schema_name The name of the schema in Model Manage.
#' @export
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

#' Remove a schema from Model Manage.
#' @return True, if successful.
#' @param schema_name The name of the schema to remove.
#' @export
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
