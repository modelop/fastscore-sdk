
SchemaMetadata <- setRefClass("SchemaMetadata",
    fields=list(
        name="character"
    )
)

Schema <- setRefClass("Schema",
    fields=list(
        name="character",
        source="list",
        model_manage="ModelManage"
        ),
    methods=list(
        update = function(model_manage=NULL){
            if(is.NULL(.self$model_manage) && is.NULL(model_manage)){
                stop(paste("FastScoreError: Schema", .self$name,
                "is not associated with Model Manage."))
            }
            if(!is.NULL(.self$model_manage)){
                .self$model_manage <- model_manage
            }
            return(.self$model_manage$save_schema(.self))
        }
    )
)
