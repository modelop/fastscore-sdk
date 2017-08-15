# format:
# https://dashboard:8000/api/1/service/{instance}/...
# = proxy_prefix/api/1/service/{instance}/

ConnectAPI <- setRefClass("ConnectAPI",
    contains="APIBase",
    fields = list(),
    methods = list(
        connect_get = function(instance, name=NULL, api=NULL){
            prefix <- proxy_prefix()
            opts <- ''
            if(!is.null(name)){
                if(nchar(opts) == 0)
                    opts <- paste(opts, '?', sep='')
                opts <- paste(opts, 'name=', name, sep='')
            }
            if(!is.null(api)){
                if(nchar(opts) == 0)
                    opts <- paste(opts, '?', sep='')
                else
                    opts <- paste(opts, '&', sep='')
                opts <- paste(opts, 'api=', api, sep='')
            }

            r <- GET(paste(prefix, instance, '/1/connect', opts, sep=''))
            if(status_code(r) != 200){
                stop("FastScoreError: Failed to retrieve configuration.")
            }
            return(content(r))
        },
        config_put_with_http_info = function(instance, config, content_type){
            prefix <- proxy_prefix()
            r <- PUT(paste(prefix, instance, '/1/config', sep=''),
                    add_headers('Content-Type'=content_type),
                    body=config)
            return(status_code(r))
        },
        config_get = function(instance, q=NULL, accept='application/x-yaml'){
            prefix <- proxy_prefix()
            opts <- ''
            if(!is.null(q)){
                opts <- paste('?q=', q, sep='')
            }
            r <- GET(paste(prefix, instance, '/1/config', opts, sep=''),
                    add_headers('accept'=accept))
            return(content(r, 'text', encoding='UTF-8'))
        }
    )
)
