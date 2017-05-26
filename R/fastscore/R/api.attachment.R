#' Add an attachment to the specified model.
#' @return True, if successful.
#' @param model_name The name of the model
#' @param attachment_file The path to the file.
#' @export
api.add_attachment <- function(model_name, attachment_file){
    if(!file.exists(attachment_file)){
      stop(paste('Attachment', attachment_file, 'not found'))
    }
    att_name <- basename(attachment_file)
    candb <- service.put('model-manage',
                paste('/1/model/', model_name,
                      '/attachment/', att_name, sep=''),
                ctype=guess_att_ctype(attachment_file), upload_file(attachment_file))
    code <- candb[[1]]
    if(code == 201){
      message(paste('Attachment', att_name, 'added to model', model_name))
      return(TRUE)
    }
    else if(code == 204){
      message(paste('Attachment', att_name, 'updated in model', model_name))
      return(TRUE)
    }
    else{
      stop(candb[[2]])
    }

}

#' Retrieve an attachment from a model, and save it to a file.
#' @return True, if successful.
#' @param model_name The name of the model.
#' @param attachment_name The name of the attachment.
#' @param attachment_path The path to save the attachment to (optional;
#'                        defaults to current working directory)
#' @export
api.get_attachment <- function(model_name, attachment_name, attachment_path=''){
    result <- service.get('model-manage', paste('/1/model/', model_name, '/attachment', sep=''))
    code <- result[[1]]
    body <- result[[2]]
    if(code == 200){
      f <- file(paste(attachment_path, attachment_name, sep=''))
      writeBin(body, f)
      close(f)
      return(TRUE)
    }
    else if(code == 404){
      message(paste('Attachment', attachment_name, 'not found'))
      return(FALSE)
    }
    else{
      stop(body)
    }
}

#' Remove the named attachment from the specified model.
#' @return True, if successful.
#' @param model_name The name of the model
#' @param attachment_name The name of the attachment
#' @export
api.remove_attachment <- function(model_name, attachment_name){
    result <- service.delete('model-manage',
                paste('/1/model/', model_name, '/attachment/', attachment_name, sep=''))
    code <- result[[1]]
    body <- result[[2]]
    if(code == 204){
      message(paste('Attachment', attachment_name, 'removed from', model_name))
      return(TRUE)
    }
    else if(code == 404){
      message(paste('Attachment', attachment_name, 'not found'))
      return(FALSE)
    }
    else{
      stop(body)
    }
}

#' List the names of all the attachments associated with the given model.
#' @return A list of all the attachments.
#' @param model_name The name of the model.
#' @export
api.list_attachments <- function(model_name){
    result <- service.get('model-manage', paste('/1/model/', model_name, '/attachment', sep=''))
    code <- result[[1]]
    if(code == 200){
      return(rjson::fromJSON(result[[2]]))
    }
    else{
      stop(result[[2]])
    }
}

guess_att_ctype <- function(resource){
    ext <- tools::file_ext(resource)
    if(ext == 'zip'){
        return('application/zip')
    }
    else if(ext=='gz'){
        return('application/gzip')
    }
    else{
        stop(paste('Attachment', resource, 'does not have a known file type (.zip or .gz)'))
    }
}
