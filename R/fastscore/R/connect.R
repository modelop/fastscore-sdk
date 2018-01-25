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

      },

      get = function(){}

      lookup = function(){}

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

