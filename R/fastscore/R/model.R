
ModelMetadata <- setRefClass("ModelMetadata",
    fields=list(
        name="character",
        mtype="character"
        ))

Model <- setRefClass("Model",
    fields=list(
        mm="ModelManage",
        name="character",
        mtype="character",
        source="character",
        ),
    methods = list(
        update = function(model_manage = NULL){
            stop("Not implemented!") # TODO
        },
        attachment_list = function(){
            stop("Not implemented!") # TODO
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
            stop("Not implemented!") # TODO
        }
        )
)
