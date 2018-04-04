#' Response Class
#'
#' Response Class
#' @export
Response  <- R6::R6Class('Response',
  inherit = swagger::Response, # (overwrite) swagger twin
  public = list(
    content = NULL,
    path = NULL,
    response = NULL,
    initialize = function(content, path, response){
      self$content <- content
      self$path <- path
      self$response <- response
    }
  )
)
