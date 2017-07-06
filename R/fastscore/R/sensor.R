
SensorMetadata <- setRefClass("SensorMetadata",
    fields=list(
        name="character"
    )
)

Sensor <- setRefClass("Sensor",
    fields=list(
        name="character",
        desc="list"
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
