EngineAPI <- setRefClass("EngineAPI",
    contains="APIBase",
    fields=list(),
    methods=list(
        input_stream_set = function(instance, desc){
            prefix <- proxy_prefix()
            body <- toJSON(desc)
            r <- PUT(paste(prefix, instance, '/1/job/stream/in', sep=''),
                     add_headers('Content-Type'='application/json'),
                     body=body)
            if(status_code(r) != 204){
                stop("FastScoreError: Invalid stream descriptor for input stream.")
            }
            return(status_code(r) == 204)
        },
        output_stream_set = function(instance, desc){
            prefix <- proxy_prefix()
            body <- toJSON(desc)
            r <- PUT(paste(prefix, instance, '/1/job/stream/out', sep=''),
                     add_headers('Content-Type'='application/json'),
                     body=body)
            if(status_code(r) != 204){
                stop("FastScoreError: Invalid stream descriptor for output stream.")
            }
            return(status_code(r) == 204)
        },
        model_load = function(instance, data, content_type, content_disposition=NULL){
            prefix <- proxy_prefix()
            body <- data
            if(!is.null(content_disposition)){
                r <- PUT(paste(prefix, instance, '/1/job/model', sep=''),
                         add_headers('Content-Type'=content_type,
                                     'Content-Disposition'=content_disposition),
                         body=body)
                if(status_code(r) != 204){
                    stop(paste("FastScoreError:", content(r, 'text', encoding='UTF-8')))
                }
                return(status_code(r) == 204)
            }
            else{
                r <- PUT(paste(prefix, instance, '/1/job/model', sep=''),
                         add_headers('Content-Type'=content_type),
                         body=body)
                if(status_code(r) != 204){
                    stop(paste("FastScoreError:", content(r, 'text', encoding='UTF-8')))
                }
                return(status_code(r) == 204)
            }
        },
        job_delete = function(instance){
            prefix <- proxy_prefix()
            r <- DELETE(paste(prefix, instance, '/1/job', sep=''))
            if(status_code(r) != 204){
                stop("FastScoreError: Unable to stop current job.")
            }
            return(status_code(r) == 204)
        },
        job_scale = function(instance, n){
            prefix <- proxy_prefix()
            r <- POST(paste(prefix, instance, '/1/job/scale?n=', n, sep=''))
            if(status_code(r) != 204){
                stop("FastScoreError: Unable to scale job.")
            }
            return(status_code(r) == 204)
        },
        stream_sample = function(instance, desc, n){
            prefix <- proxy_prefix()
            r <- POST(paste(prefix, instance, '/1/stream/sample?n=', n, sep=''),
                      body=toJSON(desc))
            return(content(r))
        },
        job_status = function(instance){
            prefix <- proxy_prefix()
            r <- GET(paste(prefix, instance, '/1/job/status', sep=''))
            return(content(r))
        },
        job_io_input = function(instance, data, id){
            prefix <- proxy_prefix()
            r <- POST(paste(prefix, instance, '/1/job/input/', id, sep=''),
                add_headers('Content-Type'='application/octet-stream'),
                body=data)
            if(status_code(r) != 204){
                stop("FastScoreError: REST stream transport not found.")
            }
            return(status_code(r) == 204)
        },
        job_io_output = function(instance, id){
            prefix <- proxy_prefix()
            r <- GET(paste(prefix, instance, '/1/job/output/', id, sep=''))

            return(content(r, 'text', encoding='UTF-8'))
        }
    )
)
