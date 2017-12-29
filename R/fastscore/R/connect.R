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

Connect <- function(InstanceBase){




}

