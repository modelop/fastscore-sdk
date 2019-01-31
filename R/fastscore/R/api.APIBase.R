APIBase <- setRefClass("APIBase",
    fields = list(),
    methods = list(
        active_sensor_available = function(name){
            stop("Not implemented!")
        },
        health_get = function(name){
          r <- GET(paste(proxy_prefix(), name, '/1/health', sep=""))
          return(status_code(r) == 200)
        },
        swagger_get = function(name){
          r <- GET(paste(proxy_prefix(), name, '/1/health', sep=""))
          if(status_code(r)){
            return(content(r) == 200)
          }
        },
        active_sensor_attach = function(name, desc){
            stop("Not implemented!")
        },
        active_sensor_detach = function(name, tapid){
            stop("Not implemented!")
        }
    )
)
