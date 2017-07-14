# class union to allow for optional parameters
setClassUnion("functionOrNull", c("function", "NULL"))
setClassUnion("characterOrNull", c("character", "NULL"))

## -- Model class -- ##
#' Model
#' A class that represents a FastScore Model.
#' @export RModel
RModel <- setRefClass("RModel",
    fields=list(
        action="function",
        input_schema="AvroType",
        output_schema="AvroType",
        options = "list",
        begin = "functionOrNull",
        end = "functionOrNull",
        functions = "list",
        attachments = "list",
        imports = "list",
        name = "characterOrNull"
    ),
    methods = list(
        score = function(inputs, complete=TRUE, use_json=FALSE){
            assign("emit", function(x){ return(x)}, environment(action))
            if(complete){
                if(!is.null(begin)){
                    begin()
                }
            }
            recordset_input <- FALSE
            recordset_output <- FALSE
            if(!is.null(.self$options[['recordsets']]))
            {
                if(.self$options[['recordsets']] == 'input')
                    recordset_input <- TRUE
                else if(.self$options[['recordsets']] == 'output')
                    recordset_output <- TRUE
                else if(.self$options[['recordsets']] == 'both'){
                    recordset_input <- TRUE
                    recordset_output <- TRUE
                }
            }

            input_data <- inputs
            if(recordset_input){
                if(use_json){
                    input_data <- recordset_from_json(input_data,
                        schema=.self$input_schema)
                }
            }
            else{
                if(use_json){
                    input_data <- lapply(input_data, from_json,
                        schema=.self$input_schema)
                }
            }
            # This is where we actually score.
            output_data <- NULL
            if(recordset_output){
                output_data <- .self$action(input_data)
                if(use_json){
                    output_data <- recordset_to_json(output_data, schema=output_schema)
                }
            }
            else{
                output_data <- lapply(input_data, action)
                if(use_json){
                    output_data <- lapply(output_data, to_json, schema=output_schema)
                }
            }
            if(complete){
                if(!is.null(end)){
                    end()
                }
            }
            return(output_data)
        },
        validate = function(inputs, outputs, use_json = FALSE){
            input_data <- inputs
            output_data <- outputs
            if(use_json){
                input_data <- lapply(inputs, from_json, schema=.self$input_schema)
                output_data <- lapply(outputs, from_json, schema=.self$output_schema)
            }
            checked_inputs <- as.logical(sapply(input_data, checkData, avroType=input_schema))
            if(!all(checked_inputs)){
                message("Invalid input(s) encountered:")
                message(inputs[which(checked_inputs != TRUE)])
                return(FALSE)
            }
            checked_outputs <- as.logical(sapply(output_data, checkData, avroType=output_schema))
            if(!all(checked_outputs)){
                message("Invalid expected output(s) encountered:")
                message(outputs[which(checked_outputs != TRUE)])
                return(FALSE)
            }
            scored_outputs <- .self$score(inputs, complete=TRUE, use_json=use_json)
            if(use_json){
              scored_outputs <- lapply(scored_outputs, from_json, schema=.self$output_schema)
            }
            if(!isTRUE(all.equal(scored_outputs, output_data))){
                message("Scored outputs differ from validation outputs:")
                for(i in 1:length(scored_outputs)){
                    if(typeof(scored_outputs[[i]]) != typeof(output_data[[i]])){
                        message(paste(scored_outputs[[i]], '!=', output_data[[i]], '(type mismatch)'))
                    }
                    if(!isTRUE(all.equal(scored_outputs[[i]], output_data[[i]]))){
                        message(paste(scored_outputs[[i]], '!=', output_data[[i]], '(value mismatch)'))
                    }
                }
                return(FALSE)
            }
            return(TRUE)
        },
        to_string = function(){
            output_str <- '# -- this model was automatically generated -- #'

            for(opt in names(options)){
                output_str <- paste(output_str,
                    paste('# fastscore.', opt, ': ', options[[opt]], sep=''), sep='\n')
            }

            for(lib in imports){
                output_str <- paste(output_str, lib, sep='\n')
            }

            # construct the strings for each function.
            # omit the <environment: ... > line if it appears.
            action_strs <- capture.output(.self$action)
            action_strs <- action_strs[grep('<environment:.*>', action_strs, invert=TRUE)]
            action_str <- paste(action_strs, collapse='\n')
            output_str <- paste(output_str, '\n', 'action', '<-', action_str, '\n', sep='')

            if(!is.null(.self$begin)){
                begin_strs <- capture.output(.self$begin)
                begin_strs <- begin_strs[grep('<environment:.*>', begin_strs, invert=TRUE)]
                begin_str <- paste(begin_strs, collapse='\n')
                output_str <- paste(output_str, '\n', 'begin', '<-', begin_str, '\n', sep='')
            }

            if(!is.null(.self$end)){
                end_strs <- capture.output(.self$end)
                end_strs <- end_strs[grep('<environment:.*>', end_strs, invert=TRUE)]
                end_str <- paste(end_strs, collapse='\n')
                output_str <- paste(output_str, '\n', 'end', '<-', end_str, '\n', sep='')
            }

            for(fcn_name in names(.self$functions)){
                fcn <- .self$functions[[fcn_name]]
                fcn_strs <- capture.output(fcn)
                fcn_strs <- fcn_strs[grep('<environment:.*>', fcn_strs, invert=TRUE)]
                fcn_str <- paste(fcn_strs, collapse='\n')
                output_str <- paste(output_str, '\n', fcn_name, '<-', fcn_str, '\n', sep='')
            }

            return(output_str)
        }
    )
)


#' @export
Model_from_string <- function(model_str, outer_namespace=new.env()){
    stopifnot(is.environment(outer_namespace))
    dictionary <- split_functions(model_str)
    model_code <- eval(parse(text=model_str), outer_namespace)
    options <- dictionary[['options']]
    libs <- dictionary[['libs']]

    model <- Model()
    if(length(options) > 0)
        model$options <- as.list(options)
    if(length(libs) > 0)
        model$imports <- as.list(libs)

    for(fcn in dictionary[['fcns']])
    {
        fcn_name <- fcn[['name']]
        if(fcn_name == 'action'){
            model$action <- outer_namespace[['action']]
        }
        else if(fcn_name == 'begin'){
            model$begin <- outer_namespace[['begin']]
        }
        else if(fcn_name == 'end'){
            model$end <- outer_namespace[['end']]
        }
        else {
            model$functions[[fcn_name]] <- outer_namespace[[fcn_name]]
        }
    }
    if(!is.null(options[['input']])){
        input_sch_name <- options[['input']]
        if(!is.null(outer_namespace[[input_sch_name]])){
            model$input_schema <- jsonNodeToAvroType(outer_namespace[[input_sch_name]])
        }
    }
    if(!is.null(options[['output']])){
        output_sch_name <- options[['output']]
        if(!is.null(outer_namespace[[output_sch_name]])){
            model$output_schema <- jsonNodeToAvroType(outer_namespace[[output_sch_name]])
        }
    }

    return(model)
}

# split a single R source string into its component import statements,
# functions, and FastScore options.
split_functions <- function(r_str){
  model_options <- list()
  model_libs <- list()
  model_fcns <- list()
  lines <- strsplit(r_str, '\n')[[1]]
  fcn_str <- ''
  fcn_name <- ''
  levels <- 0
  for(line in lines){
    option <- regmatches(line,regexec('# *fastscore\\.(.*):(.*)',line))[[1]]
    if(length(option) > 0){
      option_name <- trimws(option[[2]])
      option_value <- trimws(option[[3]])
      model_options[[option_name]] <- option_value
    }
    lib <- regmatches(line, regexec('library\\(.*\\)', line))[[1]]
    if(length(lib) > 0){
      model_libs[[length(model_libs) + 1]] <- lib[[1]]
    }
    clean_line <- line # line may be empty string...
    if(nchar(line) > 0){
      clean_line <- strsplit(line, '#')[[1]][[1]]
    }
    match <- regmatches(clean_line, regexec('(.*)<-.*function\\(', clean_line))[[1]]
    if(length(match) > 0 || grepl('\\{', clean_line)){
      if(levels == 0){
        fcn_name <- trimws(match[[2]])
      }
      levels <- levels + 1
    }
    if(levels > 0){
      fcn_str <- paste(fcn_str, line, sep='\n')
    }
    if(grepl('\\}', clean_line)){
      levels <- levels - 1
      if(levels == 0){
        fcn_str <- trimws(regmatches(fcn_str, regexpr('<-', fcn_str), invert=TRUE)[[1]][[2]])
        model_fcns[[length(model_fcns) + 1]] <- list(name=fcn_name, def=fcn_str)
        fcn_str <- ''
        fcn_name <- ''
      }
    }
  }
  return(list('fcns'=model_fcns, 'options'=model_options, 'libs'=model_libs))
}
