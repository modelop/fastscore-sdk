#' @include suite.model_manage.R

ModelMetadata <- setRefClass("ModelMetadata",
    fields=list(
        name="character",
        mtype="character"
        ))

#' @title Model
#' @description A class that represents a FastScore Model
#' @field model_manage the modelmanage it belongs to
#' @field name model name
#' @field mtype model type
#' @field source model source code
#' @export Model
Model <- setRefClass("Model",
    fields=list(
        model_manage="ModelManage",
        name="character",
        mtype="character",
        source="character"
        ),
    methods = list(
        saved = function(){
          if(is.null(.self$model_manage)){
            stop(paste("FastScoreError: Model ", .self$name, " not saved (use update() method)."))
          } else {
            return(TRUE)
          }
        },
        update = function(model_manage = NULL){
            if(is.null(model_manage) && is.null(.self$model_manage)){
                stop("FastScoreError: Model is not associated with Model Manage")
            }
            if(is.null(.self$model_manage) || !is.null(model_manage)){
                .self$model_manage <- model_manage
            }
            .self$model_manage$save_model(.self)
        },

        attachment_download = function(name){
          .self$saved()
         return(api.get_attachment(.self, name))
        },
        attachment_save = function(att){
          .self$saved()
          api.add_attachment(att$model$name, att$datafilepath)
        },
        snapshot_list = function(date1=NULL, date2=NULL, count=10){
          .self$saved()
          prefix <- proxy_prefix()
          date_range <- ""
          if(!is.null(date1)){
            data_range <- paste(data_range, as.character(date1), "--")
          }
          if(!is.null(date2)){
            data_range <- paste(data_range, as.character(date2))
          }
          r <- GET(paste(prefix, .self$model_manage$name, "/1/model/", .self$name, "/snapshot/count=", count, "&date-range=", date_range, sep=""))
          if(status_code(r) == 200){return(content(r))}
          else{stop("FastScoreError: Cannot list snapshots.")}
        },
        snapshot_get = function(snapid){
          .self$saved()
          prefix <- proxy_prefix()
          r <- GET(paste(prefix, .self$model_manage$name, "/1/model", .self$name, "/snapshot/", snapid, "/metadata", sep=""))
          if(status_code(r) == 200){return(content(r))}
          else if(status_code(r) == 300){stop("FastScoreError: The id prefix is ambiguous.")}
          else if(status_code(r) == 404){stop("FastScoreError: Snapshot not found.")}
          else{stop("FastScoreError: Error getting snapshot.")}
        },
        snapshot_delete = function(snapid){
          .self$saved()
          prefix <- proxy_prefix()
          r <- DELETE(paste(prefix, .self$model_manage$name, "/1/model", .self$name, "/snapshot/", snapid, sep=""))
          if(status_code(r) == 204){return(status_code(r))}
          else if(status_code(r) == 300){stop("FastScoreError: The id prefix is ambiguous.")}
          else if(status_code(r) == 404){stop("FastScoreError: Snapshot not found.")}
          else{stop("FastScoreError: Error deleting snapshot.")}
        },
        snapshot_download = function(snapid){
          .self$saved()
          prefix <- proxy_prefix()
          r <- GET(paste(prefix, .self$model_manage$name, "/1/model", .self$name, "/snapshot/", snapid, "/contents", sep=""))
          if(status_code(r) == 204){return(content(r))}
          else if(status_code(r) == 300){stop("FastScoreError: The id prefix is ambiguous.")}
          else if(status_code(r) == 404){stop("FastScoreError: Snapshot not found.")}
          else{stop("FastScoreError: Error deleting snapshot.")}
        },
        deploy = function(engine){
          .self$saved()
          engine$load_model(.self)
        }
      )
)

#' List all attachments of this model
#' @name Model_attachment_list
#' @return a list of attachment type and size
NULL
Model$methods(
  attachment_list = function(){
    .self$saved()
    .self$model_manage$swg$attachment_list(.self$model_manage$name, .self$name)
  },
  attachment_get = function(name){
    .self$saved()
    r <- GET(paste(proxy_prefix(), .self$model_manage$name, "/1/model/", .self$name, "/attachment/", name, sep=""))
    ct = headers(r)['content-type']
    sz = as.integer(headers(r)['content-length'])
    for(atype in names(ATTACHMENT_CONTENT_TYPES)){
      if(ATTACHMENT_CONTENT_TYPES[[atype]] == ct){
        return(list(atype, sz))
      }
    }
    return(paste("FastScoreError: Unexpected model MIME type:", ct))
  }
)

#' Delete an attachments from this model
#' @name Model_attachment_delete
#' @param name attachment name
#' @return if an attachment is successfully removed
NULL
Model$methods(
  attachment_delete = function(name){
    .self$saved()
    return(api.remove_attachment(.self$name, name))
  }
)
