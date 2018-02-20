Model <- R6::R6Class("Model",
   public = list(
     name = NA,
     mtype = NA,
     source = NA,
     model_manage = NA,
     initialize = function(name, mtype = NA, source = NA, model_manage = NA){
       self$name <- name
       self$mtype <- mtype
       self$source <- source
       self$model_manage <- model_manage
       }
     )
   )
