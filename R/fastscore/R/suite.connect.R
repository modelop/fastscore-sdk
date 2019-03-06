#' @include suite.instance.R
#' @include api.ConnectAPI.R
#' @include api.EngineAPI.R
#' @include api.ModelManageAPI.R

#' @export Connect
Connect <- setRefClass("Connect",
    contains="InstanceBase",
    fields=list(
        proxy_prefix="character",
        resolved="list",
        preferred="list",
        target="InstanceBase" #Or NULL?
    ),
    methods = list(
        initialize = function(...){
            callSuper(...)
            options('proxy_prefix'=proxy_prefix)
            .self$name <- "connect"
            .self$api <- "connect"
            .self$swg <- ConnectAPI$new()
            .self
        },
        pneumo = function(){
            return(PneumoSock$new(proxy_prefix = .self$proxy_prefix))
        },
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
        },
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
        },
        prefer = function(sname, name){
            .self$preferred[[sname]] <- name
        },
        configure = function(config){
            status <- .self$swg$config_put_with_http_info(.self$name,
                config=config,
                content_type='application/x-yaml')
            return(status == 204)
        },
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
        },
        fleet = function(){
            return(.self$swg$connect_get(.self$name))
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
