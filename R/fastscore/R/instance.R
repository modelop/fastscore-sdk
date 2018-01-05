# instance.py

# from ..errors import FastScoreError
# from ..v1.rest import ApiException
# from ..v2.models import ActiveSensorInfo

# Where (?) to put this:
# httr::set_config(httr::config(ssl_verifypeer = FALSE))


InstanceBase <- R6::R6Class("InstanceBase",
    public = list(

      name = NULL,
      api = NULL,
      # swg = NULL,
      # swg2 = NULL, # Maxim: N/A for R-SDK

      initialize = function(name = NA, api = NA, swg = NA){
        self$name <- name
        self$api <- api
        # self$swg  <- swg
        # self$swg2 <- swg2
      },

      # @property (???)
      active_sensors = function(){
        #' Currently installed sensors indexed by id
        #'
        #' > engine <- Connect$lookup('engine')
        #' > names(engine$active_sensors())
        #' > x <- engine$active_sensors["sensor"]
        #' > str(x)

        tryCatch(
          {
             d <- list()
             for(i in self$active_sensor_list(self$name)){
               d[[paste(i)]] <- i
               }
             d
            },
          error = function(e) FastScoreError$new(
            message = "Unable to retrieve active sensors.",
            caused_by = e$message
            )$error_string()
          )
      },

      # @property (???)
      tapping_points = function(){
        # List of tapping points supported by the instance
        #
        # > mod_man$tapping_points()

        tryCatch(
          self$tapping_points(self$name),

          error = function(e) FastScoreError$new(
            message = "Unable to list tapping points.",
            caused_by = e$message
            )$error_string()
        )
      },
      # calls  v2.yaml method: tapping_points(...)

      check_health = function(){
        # Retrieves version information from the instance.
        # A successful reply indicates that the instance is healthy.
        #
        # > Connect$check_health()

        tryCatch(
          self$health_get(self$name),

          error = function(e) FastScoreError$new(
            message = "Unable to retrieve instance info.",
            caused_by = e$message
            )$error_string()
        )
      },

      get_swagger = function(){},

      install_sensor = function(sensor){},

      uninstall_sensor = function(tapid){}
    )
)
