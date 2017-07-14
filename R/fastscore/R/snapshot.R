
Snapshot <- setRefClass("Snapshot",
    fields=list(
        id="character",
        date="character",
        stype="character",
        size="numeric",
        model="Model"
    ),
    methods = list(
        restore <- function(){
            .self$model$restore_snapshot(.self)
        }
    )
)
