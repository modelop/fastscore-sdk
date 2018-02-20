# library(swagger)
set_auth_cookie <- function(auth_secret, client1, client2){
  cookie <- paste0(connect$sid, auth_secret)
  client1$cookie <- cookie
  client2$cookie <- cookie
}

unset_auth_cookie <- function(client1, client2){
  client1$cookie <- NULL
  client2$cookie <- NULL
}

Connect <- R6::R6Class("Connect",

    inherit = ConnectApi, # swagger twin
    public = list(
      apiClient = NA,
      basePath = NA,
      auth_secret = NA,

      initialize = function(apiClient, basePath = NA, auth_secret = NA){

        self$auth_secret <- auth_secret
        self$apiClient <- apiClient # fastscore parent
        self$basePath <- apiClient$basePath

        self$preferred <- list()

      },

      get = function(){},

      lookup = function(sname){
        # sname: FastScore service name; e.g. 'model-manage'
        # Value: a FastScore instance object

        if("sname" %in% self$preferred){
          self$get(sname$preferred["sname"])
        }

        tryCatch(
          xx <- self$connect_get(self$name, TODO),
          error = function(e) FastScoreError$new(
            message = "Cannot retrieve fleet info.",
            caused_by = e$message
            )$error_string()
        )

        for(x in names(xx))
          if(x$health == 'ok') self$get(x$name)

        if(length(xx) == 0){
          m <- paste0("No instances of service ", sname, " configured.")
          FastScoreError$new(message = "m")$error_string()
        } else if(length(xx) == 1){
          m <- paste0(xx[1]$name, " instance is unhealthy")
          FastScoreError$new(message = "m")$error_string()
        } else {
          m <- paste0("All ", length(xx), " instances of service", sname, " unhealthy.")
          FastScoreError$new(message = "m")$error_string()
        }

      },

      fleet = function(instance){
        tryCatch(
          self$connect_get(instance),
          error = function(e) FastScoreError$new(
            message = "Cannot retrieve fleet info.",
            caused_by = e$message
          )$error_string()
        )
      }




    )
)

