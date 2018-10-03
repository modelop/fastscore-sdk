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

Connect <- R6::R6Class(
  classname = "Connect",
  inherit = swagger::ConnectApi,
  public = list(
    apiClient = NA,
    basePath = NA,
    auth_secret = NA,
    preferred = NA,

    initialize = function(apiClient, basePath = NA,
                            auth_secret = NA, preferred = NA){

      self$auth_secret <- auth_secret
      self$apiClient <- apiClient # fastscore parent
      self$basePath <- apiClient$basePath

      self$preferred <- list()
      },

    get = function(){},

    # fastscore::ModelManage$new(apiClient = api)
    lookup = function(sname){

        # sname: FastScore service name; e.g. 'model-manage'
        # Value: a FastScore instance object

        # if("sname" %in% self$preferred){
        #   self$get(sname$preferred["sname"])
        # }

        # tryCatch(
        #   xx <- self$connect_get(instance = sname), # swagger::connect_get()
        #   error = function(e) stop("Cannot retrieve fleet info, ", e$message)
        # )
        # return(xx)

        # for(x in names(xx))
        #   if(x$health == 'ok') self$get(x$name)

        # if(length(xx) == 0){
        #   stop("No instances of service ", sname, " configured.")
        #   } else if(length(xx) == 1){
        #     stop(xx[1]$name, " instance is unhealthy")
        #     } else {
        #       stop("All ", length(xx), " instances of service", sname, " unhealthy.")
        #       }
        }, # unnecessary b/c ^^

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

