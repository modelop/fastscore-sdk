#' @export InstanceBase
InstanceBase <- setRefClass("InstanceBase",
    fields = list(
        name="character",
        api="character",
        swg="APIBase"
    ),
    methods = list(
        active_sensors = function(){
            stop("Not implemented!") #TODO
        },
        tapping_points = function(){
            return(.self$swg$active_sensor_available(.self$name))
        },
        check_health = function(){
            return(.self$swg$health_get(.self$name))
        },
        get_swagger = function(){
            return(.self$swg$swagger_get(.self$name))
        },
        install_sensor = function(sensor){
            return(.self$swg$active_sensor_attach(.self$name, sensor$desc))
        },
        uninstall_sensor = function(tapid){
            return(.self$swg$active_sensor_detach(.self$name, tapid))
        }
    )

)

ActiveSensorBag <- setRefClass("ActiveSensorBag",
    fields = list(
        inst = "InstanceBase"
    ),
    methods = list(
        ids = function(){
            stop("Not implemented!") #TODO
        },
        get = function(tapid){
            stop("Not implemented!") #TODO
        },
        del = function(tapid){
            return(.self$inst$uninstall_sensor(tapid))
        }
    )
)
