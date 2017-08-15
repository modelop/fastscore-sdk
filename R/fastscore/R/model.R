#' @include suite.model_manage.R

ModelMetadata <- setRefClass("ModelMetadata",
    fields=list(
        name="character",
        mtype="character"
        ))

#' @export Model
Model <- setRefClass("Model",
    fields=list(
        model_manage="ModelManage",
        name="character",
        mtype="character",
        source="character"
        ),
    methods = list(
        update = function(model_manage = NULL){
            if(is.null(model_manage) && is.null(.self$model_manage)){
                stop("FastScoreError: Model is not associated with Model Manage")
            }
            if(is.null(.self$model_manage) || !is.null(model_manage)){
                .self$model_manage <- model_manage
            }
            .self$model_manage$save_model(.self)
        },
        attachment_list = function(){
            if(!is.null(.self$model_manage)){
                .self$model_manage$swg$attachment_list(.self$model_manage$name, .self$name)
            }
            else{
                stop("FastScoreError: Model is not associated with Model Manage")
            }
        },
        attachment_get = function(name){
            stop("Not implemented!") # TODO
        },
        attachment_download = function(name){
            stop("Not implemented!") # TODO
        },
        attachment_delete = function(name){
            stop("Not implemented!") # TODO
        },
        save_attachment = function(att){
            stop("Not implemented!") # TODO
        },
        snapshot_list = function(date1, date2, count){
            stop("Not implemented!") # TODO
        },
        snapshot_get = function(snapid){
            stop("Not implemented!") # TODO
        },
        snapshot_delete = function(snapid){
            stop("Not implemented!") # TODO
        },
        deploy = function(engine){
            engine$load_model(.self)
        }
        )
)
