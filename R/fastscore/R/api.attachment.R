api.add_attachment <- function(model_name, attachment_file){
    if(!file.exists(attachment_file)){
      stop(paste('Attachment', attachment_file, 'not found'))
    }
    att_name <- basename(attachment_file)
    candb <- service.put('model-manage',
                paste('/1/model/', model_name,
                      '/attachment/', att_name, sep=''),
                ctype=guess_att_ctype(attachment_file),
                upload_file(attachment_file))
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

api.get_attachment <- function(model, attachment_name, attachment_path=''){
    r <- GET(paste(proxy_prefix(), model$model_manage$name, '/1/model/', model$name, '/attachment/', attachment_name, sep=''))
    code <- status_code(r)
    body <- content(r)
    if(code == 200){
      f <- file(paste(attachment_path, attachment_name, sep=''), 'wb')
      writeBin(con=f,object=body)
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
    else if(ext=='gz' || ext == "tgz"){
        return('application/gzip')
    }
    else{
        stop(paste('Attachment', resource, 'does not have a known file type (.zip or .gz)'))
    }
}
