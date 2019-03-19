StringToList <- function(input){
  if(length(input) < 1){
    return("Error: No instance")
  }
  return(unlist(strsplit(input, "-4-1-8-9-8-")))
}