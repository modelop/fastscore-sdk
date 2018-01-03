# instance.py

# from ..errors import FastScoreError
# from ..v1.rest import ApiException
# from ..v2.models import ActiveSensorInfo

InstanceBase <- R6::R6Class("InstanceBase",
    public = list(

      name = NULL,
      api = NULL,
      swg = NULL,

      initialize = function(name = NA, api = NA, swg = NA){
        self$name <- name
        self$api <- api
        self$swg <- swg
      },

      # @property (???)

      active_sensors = function(self){

        tryCatch(
          {
            d <- list()
            for(i in victory$active_sensor_list(self$name)){
              d[[paste(i)]] <- i
              }
            d
            },
        error = function(e) FastScoreError$new(
          message = "Unable to retrieve active sensors.",
          caused_by = e$message)$error_string()
        # warning = FastScoreError$new(message = "...", caused_by = "..."),
        # message = FastScoreError$new(message = "...", caused_by = "...")
        )
      },

      # @property (???)
      tapping_points = function(self){},

      check_health = function(self){},

      get_swagger = function(self){},

      install_sensor = function(self, sensor){},

      uninstall_sensor = function(self, tapid){}
    )
)
