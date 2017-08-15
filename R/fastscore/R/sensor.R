#' @include suite.model_manage.R

SensorMetadata <- setRefClass("SensorMetadata",
    fields=list(
        name="character"
    )
)

#' @export Sensor
Sensor <- setRefClass("Sensor",
    fields=list(
        name="character",
        desc="list",
        model_manage="ModelManage"
    ),
    methods=list(
        install = function(where){
            where$install_sensor(.self)
        },
        update = function(model_manage=NULL){
            if(is.NULL(model_manage) && is.NULL(.self$model_manage)){
                stop(paste("FastScoreError: Sensor", .self$name,
                    "is not associated with Model Manage"))
            }
            if(!is.NULL(.self$model_manage)){
                .self$model_manage <- model_manage
            }
            return(.self$model_manage$save_sensor(.self))
        }
    )
)
