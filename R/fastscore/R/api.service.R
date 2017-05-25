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

#' @export
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

#' @export
proxy_prefix <- function(){
  if(is.null(options[['proxy-prefix']]))
  {
    stop('Not connected - set the proxy prefix!')
  }
  return(options[['proxy-prefix']])
}

#' @export
service.head <- function(name, path, generic=TRUE, preferred=list()){
  r <- HEAD(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), headers(r)))
}

#' @export
service.get <- function(name, path, generic=TRUE, preferred=list()){
  r <- GET(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

#' @export
service.get_str <- function(name, path, generic=TRUE, preferred=list()){
  r <- GET(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

#' @export
service.get_with_ct <- function(name, path, generic=TRUE, preferred=list()){
  r <- GET(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8'), headers(r)[['content-type']]))
}

#' @export
service.put <- function(name, path, ctype, data, generic=TRUE, preferred=list()){
  r <- PUT(paste(lookup(name, generic, preferred), path, sep=''),
      add_headers('content-type'=ctype), body=data)
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

#' @export
service.put_with_headers <- function(name, path, headers, data, generic=TRUE, preferred=list()){
  r <- PUT(paste(lookup(name, generic, preferred), path, sep=''),
      add_headers(headers),
      body=data)
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

#' @export
service.put_multi <- function(name, path, parts, generic=TRUE, preferred=list()){
  # The format of parts is a list of 4-item tuples
  # of the form (name, body, content-type, content-disposition)
  # e.g. ('example_py_model', '...', 'application/vnd.fastscore.model-python', 'x-model')

  # example request
  headers_model <- c('content-type'=ctype,
                     'content-disposition'=paste('x-model; name="', model_name, '"', sep=''))
  '
multipart/mixed; boundary=---------------------------636310721297930000
850
  '
  '
  -----------------------------636310721297930000
Content-Type: application/vnd.fastscore.model-python
Content-Disposition: x-model; name="example_py_model"

# fastscore.input: sch_in
# fastscore.output: sch_out
# fastscore.recordsets: both

import numpy as np
import pandas as pd
import pickle

def action(datum):
    datum[\'z\'] = model_params[\'a\']*datum[\'x\'] - model_params[\'b\']*datum[\'y\']
    yield datum


def begin():
    global model_params
    model_params = pickle.load(open(\'model_params.pkl\', \'rb\'))


-----------------------------636310721297930000
Content-Type: message/external-body; access-type="x-model-manage"; ref="urn:fastscore:attachment:example_py_model:attachment.tar.gz"

Content-Type: application/gzip
Content-Disposition: attachment; filename="attachment.tar.gz"


-----------------------------636310721297930000--
'

  boundary <- as.character(runif(1, 0, 100)) # generate a random string
  headers <- c('content-type'=paste('multipart/mixed; boundary=', boundary, sep=''))
  body <- ''
  for(part in parts){
    body <- paste(body, '--', boundary, '\r\n',
                  'Content-Type: ', part[['content-type']], '\r\n', sep='')
    if(!is.null(part[['content-disposition']])){
      body <- paste(body, 'Content-Disposition: ', part[['content-disposition']], '\r\n', sep='')
    }
    body <- paste(body, '\r\n', part[['body']], '\r\n', sep='')
  }
  body <- paste(body, '--', boundary, '--', '\r\n', sep='')

  message(body)

  r <- PUT(paste(lookup(name, generic, preferred), path, sep=''),
           add_headers(headers),
           body=body)
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

#' @export
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

#' @export
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

#' @export
service.delete <- function(name, path, generic=TRUE, preferred=list()){
  r <- DELETE(paste(lookup(name, generic, preferred), path, sep=''))
  return(list(status_code(r), content(r, 'text', encoding = 'UTF-8')))
}

#' @export
lookup <- function(name, generic, preferred=list()){
  if(generic){
    return(lookup_api(name, preferred))
  }
  else{
    return(paste(proxy_prefix(), '/api/1/service/', name, sep=''))
  }
}

#' @export
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
