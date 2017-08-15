#' @include suite.model_manage.R

StreamMetadata <- setRefClass("StreamMetaData",
    fields=list(
        name="character"
    )
)

#' @export Stream
Stream <- setRefClass("Stream",
    fields = list(
        name="character",
        desc="list",
        model_manage="ModelManage"
    ),
    methods = list(
        sample = function(engine, n=NULL){
            return(engine$sample_stream(.self, n))
        },
        update = function(model_manage = NULL){
            if(is.null(model_manage) && is.null(.self$model_manage)){
                stop(paste("FastScoreError: Stream", .self$name,
                    "is not associated with Model Manage"))
            }
            if(is.null(.self$model_manage) || !is.null(model_manage)){
                .self$model_manage <- model_manage
            }
            .self$model_manage$save_stream(.self)
        }
    )
)
