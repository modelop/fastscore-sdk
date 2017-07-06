
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
        list_attachments = function(){
            stop("Not implemented!") # TODO
        },
        get_attachment = function(name){
            stop("Not implemented!") # TODO
        },
        download_attachment = function(name){
            stop("Not implemented!") # TODO
        },
        remove_attachment = function(name){
            stop("Not implemented!") # TODO
        },
        save_attachment = function(att){
            stop("Not implemented!") # TODO
        },
        list_snapshots = function(date1, date2, count){
            stop("Not implemented!") # TODO
        },
        get_snapshot = function(snapid){
            stop("Not implemented!") # TODO
        },
        remove_snapshot = function(snapid){
            stop("Not implemented!") # TODO
        },
        deploy(engine){
            stop("Not implemented!") # TODO
        }
        )
)
