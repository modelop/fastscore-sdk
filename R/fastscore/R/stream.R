Stream <- R6::R6Class("Stream",
                     public = list(
                       name = NA,
                       source = NA,
                       model_manage = NA,
                       initialize = function(name, source = NA, model_manage = NA){
                         self$name <- name
                         self$source <- source
                         self$model_manage <- model_manage
                       }
                     )
)
