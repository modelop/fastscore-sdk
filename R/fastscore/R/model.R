# class union to allow for optional parameters
setClassUnion("functionOrNull", c("function", "NULL"))
setClassUnion("characterOrNull", c("character", "NULL"))

## -- Model class -- ##
#' Model
#' A class that represents a FastScore Model.
#' @export Model
Model <- setRefClass("Model",
    fields=list(
        action="function",
        input_schema="character",
        output_schema="character",
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
            python.exec('from fastscore.R import _R_checkData')
            checkData <- function(datum, schema, use_json){
                python.call('_R_checkData', datum, schema, use_json)
            }
            checked_inputs <- sapply(inputs, checkData, schema=input_schema, use_json=use_json)
            if(!all(checked_inputs)){
                message("Invalid input(s) encountered:")
                message(inputs[which(checked_inputs == FALSE)])
                return(FALSE)
            }
            checked_outputs <- sapply(outputs, checkData, schema=output_schema, use_json=use_json)
            if(!all(checked_outputs)){
                message("Invalid expected output(s) encountered:")
                message(outputs[which(checked_outputs == FALSE)])
                return(FALSE)
            }
            scored_outputs <- .self$score(inputs, complete=TRUE, use_json=use_json)
            if(!isTRUE(all.equal(scored_outputs, outputs))){
                message("Scored outputs differ from validation outputs:")
                for(i in 1:length(scored_outputs)){
                    if(typeof(scored_outputs[[i]]) != typeof(outputs[[i]])){
                        message(paste(scored_outputs[[i]], '!=', outputs[[i]], '(type mismatch)'))
                    }
                    if(scored_outputs[[i]] != outputs[[i]]){
                        message(paste(scored_outputs[[i]], '!=', outputs[[i]], '(value mismatch)'))
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
    python.exec('from fastscore.R import _R_split_functions')
    dictionary <- python.call('_R_split_functions', model_str)
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
            model$input_schema <- outer_namespace[[input_sch_name]]
        }
    }
    if(!is.null(options[['output']])){
        output_sch_name <- options[['output']]
        if(!is.null(outer_namespace[[output_sch_name]])){
            model$output_schema <- outer_namespace[[output_sch_name]]
        }
    }

    return(model)
}
