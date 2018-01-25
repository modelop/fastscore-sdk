InstanceBase <- R6::R6Class("InstanceBase",
    inherit = ApiClient, # swagger twin
    public = list(
      name = NA,
      api = NA,
      basePath = NA,

      initialize = function(name = NA, api = NA, basePath){

        stopifnot(grepl("://", basePath), grepl("https:", basePath)) # TODO: add FS error message
        #   FastScoreError$new(message = "basePath must be an URL, e.g. https://dashboard:8000")$error_string()
        #   FastScoreError$new(message = "basePath must use HTTPS scheme, e.g. https://dashboard:8000")$error_string()

        self$name <- name
        self$api <- api
        self$basePath <- paste0(basePath, "/",
                                  parse_url(swagger::ApiClient$new()$basePath)$path)
      },

      # @property (???)
      active_sensors = function(){
        #' Currently installed sensors indexed by id
        #' > engine <- Connect$lookup('engine')
        #' > x <- engine$active_sensors()
        #' > str(x)
        #' > x

        tryCatch(
          self$active_sensor_list(self$name),
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

      get_swagger = function(){
        # Retrieves the Swagger specification of the API
        # supported by the instance.
        #
        # > Connect$get_swagger()

        tryCatch(
          self$swagger_get(self$name),

          error = function(e) FastScoreError$new(
            message = "Unable to retrieve Swagger specification.",
            caused_by = e$message
          )$error_string()
        )
      },

      install_sensor = function(sensor){
        tryCatch(
          self$active_sensor_attach(self$name, sensor$desc),
          # swagger::ConnectApi$active_sensor_attach(...)
          error = function(e) FastScoreError$new(
            message = "Unable to install sensor.",
            caused_by = e$message
          )$error_string()
        )
      },

      uninstall_sensor = function(tapid){
        tryCatch(
          self$active_sensor_detach(self$name, tapid),
          # swagger::ConnectApi$active_sensor_detach(...)

          error = function(e) FastScoreError$new(
            message = "Unable to uninstall sensor.",
            caused_by = e$message
          )$error_string()
        )
      }
    )
)
