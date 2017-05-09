setClassUnion("characterOrNull", c("character", "NULL"))

AvroType <- setRefClass("AvroType",
    fields=list(
        name="characterOrNull"))

#' @export
AvroNull <- setRefClass("AvroNull",
    contains="AvroType",
    method=list(
      initialize=function(..., name='null'){
        callSuper(..., name=name)
      }
      ))

#' @export
AvroBoolean <- setRefClass("AvroBoolean",
  contains="AvroType",
  method=list(
    initialize=function(..., name='boolean'){
      callSuper(...,name=name)
    }
    ))

#' @export
AvroInt <- setRefClass("AvroInt",
  contains="AvroType",
  method=list(
    initialize=function(..., name='int'){
      callSuper(..., name=name)
    }
    ))

#' @export
AvroLong <- setRefClass("AvroLong",
  contains="AvroType",
  methods=list(
    initialize=function(..., name='long'){
      callSuper(..., name=name)
    }
    ))

#' @export
AvroFloat <- setRefClass("AvroFloat",
  contains="AvroType",
  methods=list(
    initialize=function(..., name='float'){
      callSuper(..., name=name)
    }
    ))

#' @export
AvroDouble <- setRefClass("AvroDouble",
  contains="AvroType",
  methods=list(
    initialize=function(..., name='double'){
      callSuper(..., name=name)
    }
    ))

#' @export
AvroBytes <- setRefClass("AvroBytes",
  contains="AvroType",
  methods=list(
    initialize=function(..., name='bytes'){
      callSuper(..., name=name)
    }
    ))

#' @export
AvroFixed <- setRefClass("AvroFixed",
  contains="AvroType",
  fields=list(
    size="numeric",
    namespace="characterOrNull"
    )
    )

#' @export
AvroString <- setRefClass("AvroString",
  contains="AvroType",
  methods=list(
    initialize=function(..., name='string'){
      callSuper(..., name=name)
    }
  ))

#' @export
AvroEnum <- setRefClass("AvroEnum",
  contains="AvroType",
  fields=list(
    symbols="list",
    namespace="characterOrNull"
    ))

#' @export
AvroArray <- setRefClass("AvroArray",
  contains="AvroType",
  fields=list(
    items="list"
    ))

#' @export
AvroMap <- setRefClass("AvroMap",
  contains="AvroType",
  fields=list(
    values="AvroType"
  ),
  methods=list(
    initialize=function(..., name='map'){
      callSuper(..., name=name)
    }
  ))

#' @export
AvroRecord <- setRefClass("AvroRecord",
  contains="AvroType",
  fields=list(
    fields="list"
    ))

#' @export
AvroUnion <- setRefClass("AvroUnion",
  contains="AvroType",
  fields=list(
    types="list"
    ),
  methods=list(
    initialize=function(..., name='union'){
      callSuper(..., name=name)
    }
    ))

# Type of a field in an AvroRecord
AvroField <- setRefClass("AvroField",
  fields=list(
    name="character",
    avroType="AvroType"
    ))

#' Convert a JSON Avro schema to an AvroType.
#' @param x The JSON Avro schema
#' @param fromString Should x be first deserialized from a string? (Default: TRUE)
#' @export
jsonNodeToAvroType <- function(x, fromString=TRUE){
  if(fromString){
    x <- rjson::fromJSON(x)
  }
  if(is.character(x) && length(x) == 1){
    if(x == 'null'){
      return(AvroNull())
    }
    else if(x == 'int'){
      return(AvroInt())
    }
    else if(x == 'boolean'){
      return(AvroBoolean())
    }
    else if(x == 'long'){
      return(AvroLong())
    }
    else if(x == 'float'){
      return(AvroFloat())
    }
    else if(x == 'double'){
      return(AvroDouble())
    }
    else if(x == 'bytes'){
      return(AvroBytes())
    }
    else if(x == 'string'){
      return(AvroString())
    }
  }
  if(is.list(x) || is.vector(x)){
    x <- as.list(x)
    type <- x[['type']]
    if(is.null(type)){
      # then we hope it's a union
      union <- AvroUnion()
      i <- 1
      for(field in x){
        union$types[[i]] <- jsonNodeToAvroType(field, fromString=FALSE)
        i <- i+1
      }
      return(union)
    }
    else if(type == 'record'){
      record <- AvroRecord()
      record$name <- x[['name']]
      record$fields <- vector(mode="list", length=length(x[['fields']]))
      i <- 1
      for(field in x[['fields']]){
        ftype <- jsonNodeToAvroType(field[['type']], fromString=FALSE)
        fname <- field[['name']]
        avrofield <- AvroField(name=fname, avroType=ftype)
        record$fields[[i]] <- avrofield
        i <- i+1
      }
      return(record)
    }
    else if(type == 'array'){
      items <- jsonNodeToAvroType(x[['items']], fromString=FALSE)
      return(AvroArray(items=items))
    }
    else if(type == 'map'){
      values <- jsonNodeToAvroType(x[['values']], fromString=FALSE)
      return(AvroMap(values=values))
    }
    else if(type == 'enum'){
      enum <- AvroEnum()
      enum$name <- x[['name']]
      enum$symbols <- x[['symbols']]
    }
    else if(type == 'fixed'){
      fixed <- AvroFixed()
      fixed$name <- x[['name']]
      fixed$size <- x[['size']]
    }
    else{
      return(jsonNodeToAvroType(type))
    }
  }
  stop(paste('Unable to decode schema', x))
}

#' Write an AvroType object to a JSON object.
#' @return A JSON object.
#' @param schema The AvroType object.
#' @param toString Should the result be a string? (Default: TRUE)
#' @export
avroTypeToJsonNode <- function(schema, toString=TRUE){
  out <- NULL
  if(class(schema) == 'AvroNull'){
    out <- 'null'
  }
  else if(class(schema) == 'AvroBoolean'){
    out <- 'boolean'
  }
  else if(class(schema) == 'AvroInt'){
    out <- 'int'
  }
  else if(class(schema) == 'AvroLong'){
    out <- 'long'
  }
  else if(class(schema) == 'AvroFloat'){
    out <- 'float'
  }
  else if(class(schema) == 'AvroDouble'){
    out <- 'double'
  }
  else if(class(schema) == 'AvroBytes'){
    out <- 'bytes'
  }
  else if(class(schema) == 'AvroString'){
    out <- 'string'
  }
  else if(class(schema) == 'AvroFixed'){
    out <- list(type='fixed', name=schema$name, size=schema$size)
  }
  else if(class(schema) == 'AvroEnum'){
    out <- list(type='enum', name=schema$name, symbols=schema$symbols)
  }
  else if(class(schema) == 'AvroArray'){
    out <- list(type='array',
                items=avroTypeToJsonNode(schema$items, FALSE))
  }
  else if(class(schema) == 'AvroMap'){
    out <- list(type='map',
                values=avroTypeToJsonNode(schema$values, FALSE))
  }
  else if(class(schema) == 'AvroRecord'){
    out <- list(type='record', name=schema$name, fields=list())
    i <- 1
    for(field in schema$fields){
      out$fields[[i]] <- list(name=field$name,
                              type=avroTypeToJsonNode(field$avroType, FALSE))
      i <- i+1
    }
  }
  else if(class(schema) == 'AvroUnion'){
    out <- lapply(schema$types, avroTypeToJsonNode, toString=FALSE)
  }
  else{
    stop('Unsupported AvroType')
  }

  if(toString){
    return(rjson::toJSON(out))
  }
  else{
    return(out)
  }
}

#' Decode a JSON object as a given fastscore.datatype.AvroType.
#' @return An R object
#' @param avroType The AvroType of this object
#' @param value A JSON object
#' @param fromString If TRUE, value is a JSON string. (Default: TRUE)
#' @export
jsonDecoder <- function(avroType, value, fromString=TRUE){
  if(fromString){
    value <- rjson::fromJSON(value)
  }
  if(class(avroType) == 'AvroNull'){
    if(is.null(value)){
      return(value)
    }
  }
  if(class(avroType) == 'AvroBoolean'){
    if(isTRUE(value) || isFALSE(value)){
      return(value)
    }
  }
  if(class(avroType) == 'AvroInt'){
    if(is.numeric(value) && value == as.integer(value)){
      return(as.integer(value))
    }
  }
  if(class(avroType) == 'AvroLong'){
    if(is.numeric(value) && value == as.integer(value)){
      return(as.integer(value))
    }
  }
  if(class(avroType) == 'AvroFloat'){
    if(is.numeric(value) && value == as.double(value)){
      return(as.double(value))
    }
  }
  if(class(avroType) == 'AvroDouble'){
    if(is.numeric(value) && value == as.double(value)){
      return(as.double(value))
    }
  }
  if(class(avroType) == 'AvroBytes'){
    if(is.character(value)){
      return(value)
    }
  }
  if(class(avroType) == 'AvroFixed'){
    if(is.character(value)){
      return(value)
    }
  }
  if(class(avroType) == 'AvroString'){
    if(is.character(value)){
      return(value)
    }
  }
  if(class(avroType) == 'AvroEnum'){
    if(is.character(value) && value %in% avroType$symbols){
      return(value)
    }
  }
  if(class(avroType) == 'AvroArray'){
    if(is.vector(value) || is.list(value)){
      return(lapply(value, jsonDecoder, avroType=avroType$items, fromString=FALSE))
    }
  }
  if(class(avroType) == 'AvroMap'){
    if(is.vector(value) || is.list(value)){
      return(lapply(value, jsonDecoder, avroType=avroType$values, fromString=FALSE, USE.NAMES=TRUE))
    }
  }
  if(class(avroType) == 'AvroRecord'){
    if(is.list(value)){
      out <- list()
      for(field in avroType$fields){
        if(field$name %in% names(value)){
          out[[field$name]] <- jsonDecoder(field$avroType, value[[field$name]], fromString=FALSE)
        }
        else if(!is.null(field$default)){
          out[[field$name]] <- jsonDecoder(field$avroType, field$default, fromString=FALSE)
        }
        else if(class(field$avroType) == 'AvroNull'){
          out[[field$name]] <- NULL
        }
        else{
          stop("Record does not match schema.")
        }
      }
      return(out)
    }
  }
  if(class(avroType) == 'AvroUnion'){
    if(is.list(value) && length(value) == 1){
      tag <- names(value)[[1]]
      val <- value[[1]]
      for(type in avroType$types){
        if(type$name == tag){
          return(jsonDecoder(type, val, fromString=FALSE))
        }
      }
    }
    if(is.null(value)){
      for(type in avroType$types){
        if(type$name == 'null'){
          return(NULL)
        }
      }
    }
  }
  stop(paste(value, 'does not match schema', avroType$name))
}

#' Encode an object as JSON, given fastscore.datatype.AvroType.
#' @return a JSON object.
#' @param avroType The type of this object.
#' @param value The contents to encode.
#' @param tagged If true, represent unions as "{tag:value}"; if false, represent them as value.
#' @param toString If true, encode the result as a JSON string (default: TRUE).
#' @export
jsonEncoder <- function(avroType, value, tagged=TRUE, toString=TRUE){
  result <- NULL
  if(class(avroType) == 'AvroNull' && is.null(value)){
    result <- value
  }
  else if(class(avroType) == 'AvroBoolean' && (isTRUE(value) || isFALSE(value))){
    result <- value
  }
  else if(class(avroType) == 'AvroInt' && (value == as.integer(value))){
    result <- as.integer(value)
  }
  else if(class(avroType) == 'AvroLong' && (value == as.integer(value))){
    result <- as.integer(value)
  }
  else if(class(avroType) == 'AvroFloat' && (value == as.double(value))){
    result <- as.double(value)
  }
  else if(class(avroType) == 'AvroDouble' && (value == as.double(value))){
    result <- as.double(value)
  }
  else if(class(avroType) == 'AvroBytes' && is.character(value)){
    result <- value
  }
  else if(class(avroType) == 'AvroFixed' && is.character(value)){
    result <- value
  }
  else if(class(avroType) == 'AvroString' && is.character(value)){
    result <- value
  }
  else if(class(avroType) == 'AvroEnum' && is.character(value) && value %in% avroType$symbols){
    result <- value
  }
  else if(class(avroType) == 'AvroArray' && (is.list(value) || is.vector(value))){
    result <- lapply(value, jsonEncoder, avroType=avroType$items, tagged=tagged, toString=FALSE)
  }
  else if(class(avroType) == 'AvroMap' && (is.list(value) || is.vector(value))){
    result <- lapply(value, jsonEncoder, avroType=avroType$values, tagged=tagged, toString=FALSE)
  }
  else if(class(avroType) == 'AvroRecord' && (is.list(value) || is.vector(value))){
    out <- list()
    for(field in avroType$fields){
      if(field$name %in% names(value)){
        out[[field$name]] <- jsonEncoder(field$avroType, value[[field$name]], tagged=tagged, toString=FALSE)
      }
      else if(!is.null(field$default)){
        next
      }
      else{
        stop(paste(value, 'does not match schema', avroType))
      }
    }
    result <- out
  }
  else if(class(avroType) == 'AvroUnion'){
    if(is.null(value) && any(class(avroType$types) == 'AvroNull')){
      result <- NULL
    }
    else if(!is.atomic(value)){
      # we're already tagged, hopefully
      type <- names(value)[[1]]
      val <- value[[1]]
      for(t in avroType$types){
        if(t$name == type){
          result <- jsonEncoder(t, val, tagged=tagged, toString=FALSE)
          break
        }
      }
    }
    else{
      for(t in avroType$types){
        tryCatch({
          out <- jsonEncoder(t, value, tagged=tagged, toString=FALSE)
          break
          },
          error = function(e){})
      }
      if(tagged){
        result <- list()
        result[[t$name]] <- out
      }
      else{
        result <- out
      }
    }
  }
  else{
    stop(paste(value, 'does not match schema', avroType))
  }

  if(toString){
    return(rjson::toJSON(result))
  }
  else{
    return(result)
  }

}

#' Check whether the given data matches the given schema.
#' @return TRUE if data satisfies avroType, and FALSE otherwise.
#' @param data The datum to test.
#' @param avroType An AvroType object.
#' @export
checkData <- function(data, avroType){
  if(class(avroType) == 'AvroNull'){
    if(is.null(data)){
      return(TRUE)
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroBoolean'){
    if(isTRUE(data) || isFALSE(data)){
      return(TRUE)
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroInt'){
    if(is.numeric(data) || (data == as.integer(data))){
      return(TRUE)
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroLong'){
      if(is.numeric(data) || (data == as.integer(data))){
        return(TRUE)
      }
      else{
        return(FALSE)
      }
  }
  if(class(avroType) == 'AvroFloat'){
    if(is.numeric(data) || (data == as.double(data))){
      return(TRUE)
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroDouble'){
    if(is.numeric(data) || (data == as.double(data))){
      return(TRUE)
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroBytes' || class(avroType) == 'AvroFixed' || class(avroType) == 'avroString'){
    if(is.character(data)){
      return(TRUE)
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroEnum'){
    if(is.character(data) && data %in% avroType$values){
      return(TRUE)
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroArray'){
    if(is.list(data) || is.vector(data)){
      return(all(lapply(data, checkData, avroType=avroType$items)))
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroMap'){
    if(is.list(data) || is.vector(data)){
      return(all(lapply(data, checkData, avroType=avroType$values)))
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroRecord'){
    if(is.list(data) || is.vector(data)){
      result <- list()
      for(field in avroType$fields){
        value <- data[[field$name]]
        result[[field$name]] <- checkData(value, field$avroType)
      }
      return(all(result))
    }
    else{
      return(FALSE)
    }
  }
  if(class(avroType) == 'AvroUnion'){
    for(type in avroType$types){
      if(checkData(data, type)){
        return(TRUE)
      }
    }
    return(FALSE)
  }
  return(FALSE)
}
