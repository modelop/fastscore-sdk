# library(swagger)

httr::set_config(httr::config(ssl_verifypeer = FALSE)) # global ignore-self-certify config

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
      proxy_prefix = NULL,
      api_client = NULL,
      auth_secret = NULL,

      initialize = function(proxy_prefix, api_client, auth_secret = NA){

        if(!grepl("://", proxy_prefix)){
          FastScoreError$new(
            message = "Proxy prefix must be an URL, e.g. https://dashboard:8000")$error_string()
          }
        if(!grepl("https:", proxy_prefix)){
          FastScoreError$new(
            message = "Proxy prefix must use HTTPS scheme")$error_string()
        }

        self$proxy_prefix <- proxy_prefix
        self$auth_secret <- auth_secret

          if (!missing(api_client)) {
            self$api_client <- api_client
          }
          else {
            self$api_client <- InstanceBase$new() # fastscore parent
          }
      },

      fleet = function(){
        tryCatch(
          self$connect_get(self$name),
          error = function(e) FastScoreError$new(
            message = "Cannot retrieve fleet info.",
            caused_by = e$message
          )$error_string()
        )
      }
    )
)

