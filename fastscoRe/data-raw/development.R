# development

# R6 =====
browseVignettes(package ="R6")

# Hadley - Advanced R - R6 classes=====
Accumulator <- R6Class("Accumulator", list(
  sum = 0,
  add = function(x = 1) {
    self$sum <- self$sum + x
    invisible(self)
  }))

x <- Accumulator$new()
x$add(4)
x$add(10)
x$sum

Person <- R6Class("Person", list(
  name = NULL,
  age = NA,
  initialize = function(name, age = NA) {
    stopifnot(is.character(name), length(name) == 1)
    stopifnot(is.numeric(age), length(age) == 1)

    self$name <- name
    self$age <- age
  }
))

hadley <- Person$new("Hadley", age = 37)

Person <- R6Class("Person", list(
  name = NULL,
  age = NA,
  initialize = function(name, age = NA) {
    self$name <- name
    self$age <- age
  },
  print = function(...) {
    cat("Person: \n")
    cat("  Name: ", self$name, "\n", sep = "")
    cat("  Age:  ", self$age, "\n", sep = "")
    invisible(self)
  } # when you print a "Person" class object,
  # it will look however you tell it to in self$print()
))

hadley2 <- Person$new("Hadley")
hadley2
