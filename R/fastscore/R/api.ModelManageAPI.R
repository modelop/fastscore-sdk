ModelManageAPI <- setRefClass("ModelManageAPI",
    contains="APIBase",
    fields=list(),
    methods=list(
        model_get_with_http_info=function(instance, name){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- GET(paste(prefix, instance, '/1/model/', name, sep=''))
            return(list(content(r, 'text', encoding='UTF-8'), status_code(r), headers(r)))
        },
        model_put_with_http_info=function(instance, name, body, content_type){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- PUT(paste(prefix, instance, '/1/model/', name, sep=''),
                    add_headers('Content-Type'=content_type),
                    body=body)
        },
        model_delete=function(instance, name){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- DELETE(paste(prefix, instance, '/1/model/', name, sep=''))
            return(status_code(r))
        },
        model_list=function(instance){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- GET(paste(prefix, instance, '/1/model', sep=''))
            return(content(r))
        },
        schema_put_with_http_info = function(instance, name, body){
            body <- toJSON(body)
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- PUT(paste(prefix, instance, '/1/schema/', name, sep=''),
                    add_headers('Content-Type'='application/json'),
                    body=body)
        },
        schema_list=function(instance){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- GET(paste(prefix, instance, '/1/schema', sep=''))
            return(content(r))

        },
        schema_get=function(instance, name){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- GET(paste(prefix, instance, '/1/schema/', name, sep=''))
            return(content(r))
        },
        schema_delete=function(instance, name){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- DELETE(paste(prefix, instance, '/1/schema/', name, sep=''))
            return(status_code(r))

        },
        stream_put_with_http_info = function(instance, name, body){
            body <- toJSON(body)
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- PUT(paste(prefix, instance, '/1/stream/', name, sep=''),
                    add_headers('Content-Type'='application/json'),
                    body=body)
        },
        stream_list=function(instance){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- GET(paste(prefix, instance, '/1/stream', sep=''))
            return(content(r))
        },
        stream_get=function(instance, name){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- GET(paste(prefix, instance, '/1/stream/', name, sep=''))
            return(content(r))
        },
        stream_delete=function(instance, name){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- DELETE(paste(prefix, instance, '/1/stream/', name, sep=''))
            return(status_code(r))
        },
        sensor_put_with_http_info = function(instance, name, body){
            body <- toJSON(body)
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- PUT(paste(prefix, instance, '/1/sensor/', name, sep=''),
                    add_headers('Content-Type'='application/json'),
                    body=body)
        },
        sensor_list=function(instance){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- GET(paste(prefix, instance, '/1/sensor', sep=''))
            return(content(r))
        },
        sensor_get=function(instance, name){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- GET(paste(prefix, instance, '/1/sensor/', name, sep=''))
            return(content(r))
        },
        sensor_delete=function(instance, name){
            prefix <- paste(getOption('proxy_prefix'), '/api/1/service/', sep='')
            r <- DELETE(paste(prefix, instance, '/1/sensor/', name, sep=''))
            return(status_code(r))
        },

    )
)
