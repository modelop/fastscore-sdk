#' Convert the specified datum into JSON strings using the schema
#' @return A JSON string.
#' @param datum An R object to encode.
#' @param schema An Avro schema to use to encode.
#' @examples
#' mylist <- as.list(c(1, 2, 3, 4))
#' lapply(mylist, to_json, schema=jsonNodeToAvroType('["null", "int"]'))
#' @export
to_json <- function(datum, schema){
    jsonEncoder(schema, datum)
}

#' Deserialize a JSON string into an R object.
#' @return An object.
#' @param datum The JSON string to deserialize.
#' @param schema The Avro schema to use for deserialization.
#' @examples
#' mylist <- as.list(c('{"int":1}', '{"int":2}', '{"int":3}'))
#' lapply(mylist, from_json, schema=jsonNodeToAvroType('["null", "int"]'))
#' @export
from_json <- function(datum, schema){
    jsonDecoder(schema, datum)
}

#' Deserialize a list of JSON strings (representing a record set)
#' into a data frame or matrix.
#' @param data The list of JSON strings
#' @param schema The Avro schema to use for deserialization
#' @examples
#' schem <- jsonNodeToAvroType('{"type":"record", "name":"myrecord", "fields":[{"type":"int", "name":"x"}, {"type":"int", "name":"y"}]}')
#' jsonlist <- list('{"x":1, "y":2}', '{"x":2, "y":3}', '{"x":2, "y":4}')
#' recordset_from_json(jsonlist, schem)
#' @export
recordset_from_json <- function(data, schema){
    records <- lapply(data, from_json, schema=schema)
    if(length(records) == 0){
        return(data.frame())
    }
    else{
        head <- records[[1]]
        cols <- names(head)
        if(is.null(cols)){
            return(matrix(unlist(records), ncol = length(head), byrow = TRUE))
        }
        else{
            if(is.null(cols))
                cols <- 1:length(records[[1]])
            Pivot <- function(col) {
                unlist(lapply(records, FUN = function(r) unname(r[col])))
            }
            df <- data.frame(lapply(cols, Pivot))
            names(df) <- cols
            return(df)
        }
    }
}

#' Serialize a record set into a list of JSON strings
#' @param recordset The record set (a Data Frame or Matrix)
#' @param schema The Avro schema to use
#' @export
recordset_to_json <- function(recordset, schema){
    out <- list()
    if(is.matrix(recordset)){
        if(nrow(recordset) > 0){
            for(i in 1:nrow(recordset)){
                out[[i]] <- to_json(recordset[i,], schema)
            }
        }
    } else{
        stopifnot(is.data.frame(recordset))
        if(nrow(recordset) > 0){
            for(i in 1:nrow(recordset)){
                out[[i]] <- to_json(as.list(recordset[i,, drop=FALSE]), schema)
            }
        }
    }
    return(out)
}
