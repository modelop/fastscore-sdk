#' Add a model to Model Manage.
#' @return True, if successful.
#' @param model_name The name of the model
#' @param model_content The contents of the model
#' @param model_type The language the model is written in (default: R)
#' @export
api.add_model <- function(model_name, model_content, model_type='R'){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.add_model', model_name, model_content, model_type)
  if(result){
      message(paste("Model", model_name, "added to Model Manage."))
  }
  return(result)
}

#' Retrieve a model's contents from Model Manage.
#' @return The contents of the model, and, optionally, its content-type header.
#' @param model_name The name of the model to retrieve
#' @param include_ctype Whether to return the content-type as well (default: False)
#' @export
api.get_model <- function(model_name, include_ctype=FALSE){
  python.exec('import fastscore.api')
  python.call('fastscore.api.get_model', model_name, include_ctype)
}

#' Remove the named model from Model Manage.
#' @return True, if successful
#' @param model_name The name of the model to remove.
#' @export
api.remove_model <- function(model_name){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.remove_model', model_name)
  if(result){
      message(paste("Model", model_name, "removed from Model Manage."))
  }
  return(result)
}

#' List all of the models in Model Manage, by name.
#' @return A list of the names of the models in Model Manage.
#' @export
api.list_models <- function(){
  python.exec('import fastscore.api')
  as.list(python.call('fastscore.api.list_models'))
}
