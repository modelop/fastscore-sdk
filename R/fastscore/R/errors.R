# Compare to errors.py


AvroCondition <- R6::R6Class("AvroException",
    # Condition for errors in serializing or deserializing Avro data.
    inherit = RuntimeError,
    public = list(
      initialize = function(){
      }
    ))


SchemaParseCondition <- R6::R6Class("SchemaParseCondition",
    # Condition for errors in parsing an Avro schema.inherit = RuntimeError,
    public = list(
      initialize = function(){}
    ))


FastScoreError <- R6::R6Class("FastScoreError",
    #' A FastScore condition (error, warning, message). SDK functions throw only FastScoreError conditions. An SDK function either succeeds or throws a condition. The return value of a SDK function is always valid.
    # inherit = condition, # Not sure about this
    public = list(
      message = NULL,
      caused_by = NULL,
      initialize = function(message = NA, caused_by = NA){
        self$message <- message # What is R equivalent?
        self$caused_by <- caused_by # Condition
      },
      error_string = function(){
        if(!is.na(self$caused_by)){
               paste0("Error: ", self$message, "  Caused by: ",
                      self$caused_by, sep = "")
        } else{
          paste0("Error: ", self$message)
        }
      }
    )
)
