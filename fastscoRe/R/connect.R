Connect <- R6::R6Class(
  classname = "Connect",
  public = list(
    userAgent = swagger::ConnectApi$public_fields$userAgent,
    apiClient = NULL,
    initialize = function(apiClient){
      if (!missing(apiClient)) {
        self$apiClient <- apiClient
      }
      else {
        self$apiClient <- ApiClient$new()
      }
      },
    active_sensor_install = function(instance, desc, ...){
      swagger::ConnectApi$public_methods$active_sensor_install(
        instance = instance, desc = desc, ...)
    },
    active_sensor_list = function(instance, ...){
      swagger::ConnectApi$public_methods$active_sensor_list(instance = instance, ...)
    },
    active_sensor_points = function(instance, ...){
      swagger::ConnectApi$public_methods$active_sensor_points(instance = instance, ...)
    }
    active_sensor_uninstall = function(instance, tap_id, ...){
      swagger::ConnectApi$public_methods$active_sensor_uninstall(
        instance = instance, tap_id = tap_id, ...)
    }
    pneumo_get = function(instance, ...){
      swagger::ConnectApi$public_methods$pneumo_get(instance = instance, ...)
    }


    )
)

