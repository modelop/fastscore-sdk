#' Connect to the FastScore Fleet.
#' @return True, if successful.
#' @export
api.connect <- function(proxy_prefix){
  test_url <- paste(proxy_prefix, '/api/1/service/connect/1/health', sep='')
  last_status <- ping_url(test_url)
  if(last_status == 200){
    options[['proxy_prefix']] <- proxy_prefix
    message('Proxy prefix set; connected to FastScore fleet.')
  }
  else if(last_status == 401){
    stop('Access denied (bad credentials?)')
  }
  else{
    stop('Not connected (is FastScore suite running?)')
  }
}

ping_url <- function(test_url){
  r <- GET(test_url)
  return(status_code(r))
}
