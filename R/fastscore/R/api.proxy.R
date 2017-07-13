

proxy_prefix <- function(){
    prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
    return(prefix)
}
