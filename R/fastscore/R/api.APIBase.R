APIBase <- setRefClass("APIBase",
    fields = list(),
    methods = list(
        active_sensor_available = function(name){
            stop("Not implemented!")
        },
        health_get = function(name){
            stop("Not implemented!")
        },
        swagger_get = function(name){
            stop("Not implemented!")
        },
        active_sensor_attach = function(name, desc){
            stop("Not implemented!")
        },
        active_sensor_detach = function(name, tapid){
            stop("Not implemented!")
        }
    )
)
