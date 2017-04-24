#' List all of the schemata in Model Manage, by name.
#' @return A list of the names of every schema in Model Manage.
#' @export
api.list_schemata <- function(){
  python.exec('import fastscore.api')
  as.list(python.call('fastscore.api.list_schemata'))
}

#' Add a schema to Model Manage.
#' @return True if successful.
#' @param schema_name The name of the schema in Model Manage
#' @param schema_content The Avro schema (a JSON string)
#' @export
api.add_schema <- function(schema_name, schema_content){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.add_schema', schema_name, schema_content)
  if(result){
      message(paste("Schema", schema_name, "added to Model Manage."))
  }
  return(result)
}

#' Retrieve a schema from Model Manage.
#' @return The contents of the named schema (a JSON string)
#' @param schema_name The name of the schema in Model Manage.
#' @export
api.get_schema <- function(schema_name){
  python.exec('import fastscore.api')
  return(python.call('fastscore.api.get_schema', schema_name))
}

#' Remove a schema from Model Manage.
#' @return True, if successful.
#' @param schema_name The name of the schema to remove.
#' @export
api.remove_schema <- function(schema_name){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.remove_schema', schema_name)
  if(result){
      message(paste("Schema", schema_name, "removed from Model Manage."))
  }
  return(result)
}
