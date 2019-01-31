#' @include model.R

#' @export Attachement
Attachement <- setRefClass("Attachement",
                     fields=list(
                       model="Model",
                       name="character",
                       atype="character",
                       datasize="integer",
                       datafilepath="character"
                     ),
                     methods = list(
                       update = function(model=NULL){
                         if(is.null(.self$model) && is.null(model)){
                           stop(paste("FastScoreError: Attachement", .self$name,
                                      "is not associated with Model."))
                         }
                         if(is.null(.self$model) || !is.null(model)){
                           .self$model <- model
                         }
                         .self$model$attachment_save(.self)
                       },
                       filepath = function(filepath = NULL){
                         if(!is.null(filepath)){
                           .self$datafilepath <- filepath
                           .self$datasize <- file.size(filepath)
                         }
                         else if(is.null(.self$datafilepath)){
                           .self$datafilepath <- .self$model$attachment_download(.self$name)
                         }
                         return(.self$datafilepath)
                       }
                     )
)
