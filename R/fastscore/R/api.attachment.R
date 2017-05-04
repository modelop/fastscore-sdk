#' Add an attachment to the specified model.
#' @return True, if successful.
#' @param model_name The name of the model
#' @param attachment_file The path to the file.
#' @export
api.add_attachment <- function(model_name, attachment_file){
    python.exec('import fastscore.api')
    result <- python.call('fastscore.api.add_attachment', model_name, attachment_file)
    if(result){
        message(paste('Attachment', attachment_file, 'added to model', model_name))
    }
    return(result)
}

#' Retrieve an attachment from a model, and save it to a file.
#' @return True, if successful.
#' @param model_name The name of the model.
#' @param attachment_name The name of the attachment.
#' @param attachment_path The path to save the attachment to (optional;
#'                        defaults to current working directory)
#' @export
api.get_attachment <- function(model_name, attachment_name, attachment_path=''){
    python.exec('import fastscore.api')
    result <- python.call('fastscore.api.get_attachment', model_name,
                          attachment_name, attachment_path)
    if(result){
        message(paste('Attachment', attachment_name, 'saved to', attachment_path))
    }
    return(result)
}

#' Remove the named attachment from the specified model.
#' @return True, if successful.
#' @param model_name The name of the model
#' @param attachment_name The name of the attachment
#' @export
api.remove_attachment <- function(model_name, attachment_name){
    python.exec('import fastscore.api')
    result <- python.call('fastscore.api.remove_attachment', model_name, attachment_name)
    if(result){
        message(paste('Attachment', attachment_name, 'removed from', model_name))
    }
    return(result)
}

#' List the names of all the attachments associated with the given model.
#' @return A list of all the attachments.
#' @param model_name The name of the model.
#' @export
api.list_attachments <- function(model_name){
    python.exec('import fastscore.api')
    as.list(python.call('fastscore.api.list_attachments', model_name))
}
