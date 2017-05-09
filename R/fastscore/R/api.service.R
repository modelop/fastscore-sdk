RELEASE <- '1.4'
API_NAMES <- list('engine', 'model-manage', 'engine-x')
options <- new.env()

resolved <- list()

.onLoad <- function(libname, pkgname){
  options[['engine-api']] <- 'engine-x'
  options[['verbose']] <- 0
  options[['wait']] <- FALSE
  # stopifnot(file.exists('.fastscore')))
  if(file.exists('.fastscore')){
    loaded <- yaml.load_file('.fastscore')
    for(name in names(loaded)){
      options[[name]] <- loaded[[name]]
    }
  }
  httr::set_config(config(ssl_verifypeer=0L))
}

update_config <- function(){
  opt_names <- list('proxy-prefix', 'auth-secret', 'engine-api')
  fileconn <- file('.fastscore')
  for(opt in opt_names){
    if(!is.null(options[[opt]])){
      writeLines(paste(opt, ': ', options[[opt]], sep=NULL), fileconn)
    }
  }
  close(fileconn)
}

proxy_prefix <- function(){
  if(is.null(options[['proxy-prefix']]))
  {
    stop('Not connected - set the proxy prefix!')
  }
  return(options[['proxy-prefix']])
}

service.head <- function(name, path, generic=TRUE, preferred=list()){
  r <- HEAD(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), headers(r)))
}

service.get <- function(name, path, generic=TRUE, preferred=list()){
  r <- GET(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

service.get_str <- function(name, path, generic=TRUE, preferred=list()){
  r <- GET(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

service.get_with_ct <- function(name, path, generic=TRUE, preferred=list()){
  r <- GET(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8'), headers(r)[['content-type']]))
}

service.put <- function(name, path, ctype, data, generic=TRUE, preferred=list()){
  r <- PUT(paste(lookup(name, generic, preferred), path, sep=''),
      add_headers('content-type'=ctype), body=data)
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

service.put_with_headers <- function(name, path, headers, data, generic=TRUE, preferred=list()){
  r <- PUT(paste(lookup(name, generic, preferred), path, sep=''),
      add_headers(headers),
      body=data)
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

service.put_multi <- function(name, path, parts, generic=TRUE, preferred=list()){
  r <- PUT(paste(lookup(name, generic, preferred), path, sep=''),
           body=data,
           encode='multipart')
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

service.post <- function(name, path, ctype=NULL, data=NULL, generic=TRUE, preferred=list()){
  if(!is.null(ctype)){
    r <- POST(paste(lookup(name, generic, preferred), path, sep=''),
              add_headers('content-type'=ctype),
              body=data)
    return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
  }
  else{
    r <- POST(paste(lookup(name, generic, preferred), path, sep=''),
              body=data)
    return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
  }
}

service.post_with_ct <- function(name, path, ctype=NULL, data=NULL, generic=TRUE, preferred=list()){
  if(!is.null(ctype)){
    r <- POST(paste(lookup(name, generic, preferred), path, sep=''),
              add_headers('content-type'=ctype),
              body=data)
    return(list(status_code(r), content(r, 'text', encoding = 'UTF-8'), headers(r)[['content-type']]))
  }
  else{
    r <- POST(paste(lookup(name, generic, preferred), path, sep=''),
              body=data)
    return(list(status_code(r), content(r, 'text', encoding = 'UTF-8'), headers(r)[['content-type']]))
  }
}

service.delete <- function(name, path, generic=TRUE, preferred=list()){
  r <- DELETE(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

lookup <- function(name, generic, preferred=list()){
  if(generic){
    return(lookup_api(name, preferred))
  }
  else{
    return(paste(proxy_prefix(), '/api/1/service/', name, sep=''))
  }
}

lookup_api <- function(api, preferred=list()){
  if(!is.null(preferred[[api]])){
    name <- preferred[[api]]
    r <- GET(paste(proxy_prefix(), '/api/1/service/connect/1/connect?name=', name, sep=''))
    if(status_code(r) != 200){
      stop(content(r))
    }
    fleet <- content(r)
    if(length(fleet) == 0){
      stop(paste('No instances of', name, 'found!'))
    }
    x <- fleet[[1]]
    if(x[['health']] == 'ok'){
      prefix <- paste(proxy_prefix(), '/api/1/service/', name, sep='')
      resolved[[api]] <- prefix
      return(prefix)
    }
    else
    {
      stop(paste(name, 'is not healthy!'))
    }
  }
  if(!is.null(resolved[[api]])){
    return(resolved[[api]])
  }
  else{
    r <- GET(paste(proxy_prefix(), '/api/1/service/connect/1/connect?api=', api, sep=''))
    if(status_code(r) != 200){
      stop(content(r))
    }
    fleet <- content(r)
    if(length(fleet) == 0){
      stop(paste('No instances of', api, 'found!'))
    }
    for(x in fleet){
      if(x[['health']] == 'ok'){
        prefix <- paste(proxy_prefix(), '/api/1/service/', x[['name']], sep='')
        resolved[[api]] <- prefix
        return(prefix)
      }
    }
    stop(paste('No healthy instances of', api, 'found!'))
  }
}

service.engine_api_name <- function(){
  return('engine-x')
}
