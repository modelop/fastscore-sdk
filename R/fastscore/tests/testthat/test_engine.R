context("Engine Test")

setwd("~/Documents/GitHub")
connect <- Connect(proxy_prefix="https://localhost:8000")
engine <- connect$get("engine-1")
mm <- connect$get("model-manage-1")

schema <- Schema(name = "array-double",
                 source = fromJSON(file="./fastscore/library/schemas/array-double.avsc"),
                 model_manage = mm)
mm$save_schema(schema)

test_that("test_load_model",
          {
            input_str <- Stream(name = "array-double-input",
                                desc = fromJSON(file = "./fastscore/library/streams/array-double-input.json"),
                                model_manage = mm)
            mm$save_stream(input_str)
            expect_true(engine$input_set(slot = 0, stream = input_str))

            output_str <- Stream(name = "array-double-output", desc = fromJSON(file = "./fastscore/library/streams/array-double-output.json"), model_manage = mm)
            mm$save_stream(output_str)
            expect_true(engine$output_set(slot = 1, stream = output_str))

            model <- Model(name = "echo-array-double.R", mtype = "R",
                           source = paste(readLines("./fastscore/library/models/echo-array-double.R"), collapse="\n"),
                           model_manage = mm)
            mm$save_model(model)
            expect_true(engine$load_model(model))

            mm$model_delete(model$name)
            mm$stream_delete(input_str$name)
            mm$stream_delete(output_str$name)
          }
)
test_that("test_sample_stream",
          {
            #TODO
          }
)
test_that("test_unload_model",
          {
            expect_true(engine$unload_model())
          }
)
test_that("test_check_health",
          {
            expect_true(engine$check_health())
          }
)

