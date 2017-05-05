#' Add a model to Model Manage.
#' @return True, if successful.
#' @param model_name The name of the model
#' @param model_content The contents of the model
#' @param model_type The language the model is written in (default: R)
#' @export
api.add_model <- function(model_name, model_content, model_type='R'){
  ctype <- ''
  if(model_type == 'python2'){
    ctype <- 'application/vnd.fastscore.model-python2'
  }
  else if(model_type == 'python3'){
    ctype <- 'application/vnd.fastscore.model-python3'
  }
  else if(model_type == 'r' || model_type == 'R'){
    ctype <- 'application/vnd.fastscore.model-r'
  }
  else if(model_type == 'pfa' || model_type == 'PFA'){
    ctype <- 'application/vnd.fastscore.model-pfa-json'
  }
  else if(model_type == 'PrettyPFA'){
    ctype <- 'application/vnd.fastscore.model-pfa-pretty'
  }
  else{
    stop(paste('Unknown model type:', model_type))
  }
  result <- service.put('model-manage', paste('/1/model/', model_name, sep=''),
                        ctype, model_content)
  if(result[[1]] == 201){
    message(paste('Model', model_name, 'added to Model Manage.'))
    return(TRUE)
  }
  else if(result[[1]] == 204){
    message(paste('Model', model_name, 'updated in Model Manage.'))
    return(TRUE)
  }
  else{
    stop(result[[2]])
  }
}

#' Retrieve a model's contents from Model Manage.
#' @return The contents of the model, and, optionally, its content-type header.
#' @param model_name The name of the model to retrieve
#' @param include_ctype Whether to return the content-type as well (default: False)
#' @export
api.get_model <- function(model_name, include_ctype=FALSE){
  result <- service.get_with_ct('model-manage', paste('/1/model/', model_name, sep=''))
  if(result[[1]] == 200){
    if(include_ctype){
      return(c(result[[2]], result[[3]]))
    }
    else{
      return(result[[2]])
    }
  }
  else if(result[[1]] == 404){
    stop(paste('Model not found:', model_name))
  }
  else{
    stop(result[[2]])
  }
}

#' Remove the named model from Model Manage.
#' @return True, if successful
#' @param model_name The name of the model to remove.
#' @export
api.remove_model <- function(model_name){
  result <- service.delete('model-manage', paste('/1/model/', model_name, sep=''))
  if(result[[1]] == 404){
    stop(paste('Model', model_name, 'not found'))
  }
  else if(result[[1]] == 204){
    message(paste('Model', model_name, 'removed from Model Manage.'))
    return(TRUE)
  }
  else{
    stop(result[[2]])
  }
}

#' List all of the models in Model Manage, by name.
#' @return A list of the names of the models in Model Manage.
#' @export
api.list_models <- function(){
  result <- service.get('model-manage', '/1/model?return=type')
  if(result[[1]] == 200){
    return(result[[2]])
  }
  else{
    stop(result[[2]])
  }
}
