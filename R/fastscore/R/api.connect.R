#' Connect to the FastScore Fleet.
#' @return True, if successful.
#' @export 
api.connect <- function(proxy_prefix){
  python.exec('import fastscore.api')
  result <- python.call('fastscore.api.connect', proxy_prefix)
  if(result){
      message("Proxy prefix set, connected to FastScore fleet.")
  }
  return(result)
}
