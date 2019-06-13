#' @include suite.instance.R
#' @include api.ConnectAPI.R
#' @include api.EngineAPI.R
#' @include api.ModelManageAPI.R


#' @description Reference class for Fastscore Connect instance
#' @title Connect
#' @export Connect
#' @field proxy_prefix proxy string
#' @field insecure indicator for insecure curl option
Connect <- setRefClass("Connect",
    contains="InstanceBase",
    fields=list(
        proxy_prefix="character",
        resolved="list",
        preferred="list",
        target="InstanceBase", #Or NULL?
        insecure="logical"
    ),
    methods = list(
        initialize = function(...){
            callSuper(...)
            options('proxy_prefix'=proxy_prefix)
            .self$name <- "connect"
            .self$api <- "connect"
            .self$swg <- ConnectAPI$new()
            .self

            if(!("insecure" %in% names(list(...)))){
              .self$insecure <- FALSE
            }
            if(insecure == TRUE){
              httr::set_config(config(ssl_verifyhost = FALSE, ssl_verifypeer = FALSE))
            }
        },
        pneumo = function(){
            return(PneumoSock$new(proxy_prefix = .self$proxy_prefix))
        },
        prefer = function(sname, name){
            .self$preferred[[sname]] <- name
        },
        dump = function(savefile){
            cap <- list(
                'proxy-prefix'=.self$proxy_prefix,
                'preferred'=.self$preferred,
                'target-name'=.self$target$name
            )
            write(as.yaml(cap), savefile)
        }
    )
)


#' Find a Fastscore instance by type
#' @name Connect_lookup
#' @param sname instance type name
#' @return an sintance object of the specified type
NULL
Connect$methods(
  lookup = function(sname){
    if(sname %in% names(preferred)){
      return(.self$get(preferred[[sname]]))
    }
    xx <- .self$swg$connect_get(.self$name, api=sname)
    for(x in xx){
      if(x[['health']] == 'ok'){
        return(.self$get(x[['name']]))
      }
    }
    if(length(xx) == 0){
      stop(paste("FastScoreError: No instances of", sname, "configured"))
    }
    else if(length(xx) == 1){
      stop(paste("FastScoreError:", xx[[1]][['name']], "instance is unhealthy"))
    }
    else{
      stop(paste("FastScoreError: All instances of service", sname, "are unhealthy"))
    }
  }
)

#' Find a Fastscore instance by name
#' @name Connect_get
#' @param name instance name
#' @return an sintance object of the specified name
NULL
Connect$methods(
  get = function(name){
    if(name == 'connect'){
      return(.self)
    }
    if(name %in% names(.self$resolved)){
      return(.self$resolved[[name]])
    }
    xx <- .self$swg$connect_get(.self$name, name=name)
    if(length(xx) > 0 && xx[[1]][['health']] == 'ok'){
      x <- xx[[1]]
      instance <- Connect.make_instance(x[['api']], name)
      .self$resolved[[name]] <- instance
      return(instance)
    }
    if(length(xx) == 0){
      stop(paste("FastScoreError: Instance", name, "not found"))
    }
    else{
      stop(paste("FastScoreError: Instance", name, "is unhealthy"))
    }
  }
)

#' Set Fastscore configuration
#' @name Connect_configure
#' @param config configuration description yaml
#' @return if configuration successfully set
NULL
Connect$methods(
  configure = function(config){
    status <- .self$swg$config_put_with_http_info(.self$name,
                                                  config=config,
                                                  content_type='application/x-yaml')
    return(status == 204)
  }
)

#' Get Fastscore configuration
#' @name Connect_get_config
#' @return configuration in yaml
NULL
Connect$methods(
  get_config = function(section=NULL){
    if(!is.null(section)){
      conf <- .self$swg$config_get(.self$name,
                                   q=section,
                                   accept='application/x-yaml')
    }
    else{
      conf <- .self$swg$config_get(.self$name,
                                   accept='application/x-yaml')
    }
    return(yaml.load(conf))
  }
)

#' Check Fastscore fleet
#' @name Connect_fleet
#' @return a list of fleet information
NULL
Connect$methods(
  fleet = function(){
    return(.self$swg$connect_get(.self$name))
  }
)


Connect.make_instance <- function(api, name){
  if(api == 'model-manage'){
    return(ModelManage$new(name=name, api=api, swg=ModelManageAPI$new()))
  }
  else if(api == 'engine'){
    return(Engine$new(name=name, api=api, swg=EngineAPI$new()))
  }
  else{
    stop("FastScoreError: Unknown API")
  }
}


Connect.load <- function(savefile){
  cap <- yaml.load_file(savefile)
  co <- Connect$new(cap[['proxy-prefix']])
  co$preferred <- cap[['preferred']]
  if(!is.null(cap[['target-name']])){
    co$target <- co$get(cap[['target-name']])
  }
  return(co)
}
