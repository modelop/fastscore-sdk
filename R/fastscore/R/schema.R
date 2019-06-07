#' @include suite.model_manage.R

setClassUnion("characterOrList", c("character", "list"))

SchemaMetadata <- setRefClass("SchemaMetadata",
    fields=list(
        name="character"
    )
)

#' Schema object for Fastscore
#' @export Schema
Schema <- setRefClass("Schema",
    fields=list(
        name="character",
        source="characterOrList",
        model_manage="ModelManage"
        ),
    methods=list(
        update = function(model_manage=NULL){
            if(is.null(.self$model_manage) && is.null(model_manage)){
                stop(paste("FastScoreError: Schema", .self$name,
                "is not associated with Model Manage."))
            }
            if(is.null(.self$model_manage) || !is.null(model_manage)){
                .self$model_manage <- model_manage
            }
            .self$model_manage$save_schema(.self)
        }
    )
)
