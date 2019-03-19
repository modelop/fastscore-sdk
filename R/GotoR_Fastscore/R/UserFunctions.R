#' import a list of certain instances from a given directory
#' @export
#' @param namelist a list of instance names
#' @param type instance type
#' @param dir directory path (example: ".../fastscore/library/")
import <- function (namelist, type, dir) {
  if (length(namelist) < 1){
    return ("Please input a list of names.")
  }
  if (type != "model" & type != "schema" & type != "stream"){
    return (paste("Type ", type, " not supported for import. (Try model/schema/stream"), sep = "")
  }
  if (type == "schema"){
    for (x in namelist) {
      dir <- paste(lib, type, "s/", x, ".avsc", sep = "")
      Schema_add(x, dir)
    }
  } else if (type == "stream"){
    for (x in namelist) {
      dir <- paste(lib, type, "s/", x, ".json", sep = "")
      Stream_add(x, dir)
    }
  } else {
    for (x in namelist) {
      dir <- paste(lib, type, "s/", x, sep = "")
      Model_add(x, dir)
    }
  }
}

#' remove all model/stream/schema loaded
#' @export
#' @param type type of instance to clear
remove_all <- function(type){
  if (type != "model" & type != "schema" & type != "stream"){
    return (paste("Type ", type, " not supported for remove. (Try model/schema/stream"), sep = "")
  }
  if (type == "schema"){ for (x in Schema_list()) {Schema_remove(x) } } 
  else if (type == "stream"){ for (x in Stream_list()) {Stream_remove(x) } }
  else { 
    for (x in Model_list()) {
      y <- strsplit(x, " | ")[[1]][1]
      Model_remove(y) 
    } 
  }
}