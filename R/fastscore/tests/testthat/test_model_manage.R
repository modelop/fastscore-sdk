context("Model-Manage Test")

setwd("~/Documents/GitHub")
connect <- Connect(proxy_prefix="https://localhost:8000")
mm <- connect$get("model-manage-1")

test_that("test_stream",
          {
            str <- Stream(name = "array-double-input",
                          desc = fromJSON(file = "./fastscore/library/streams/array-double-input.json"),
                          model_manage = mm)
            mm$stream_delete(str$name)
            expect_identical(mm$save_stream(str), "New stream loaded into ModelManage.")
            expect_gt(length(mm$stream_list()), 0)
            expect_identical(mm$save_stream(str), "Existing stream updated.")
            expect_equal(mm$stream_delete(str$name), 204)
            expect_is(mm$stream_get("demo-1"), "Stream")
          }
)
test_that("test_model",
          {
            model <- Model(name = "sum-of-doubles.R", mtype = "R",
                           source = paste(readLines("./fastscore/library/models/echo-array-double.R"), collapse="\n"),
                           model_manage = mm)
            mm$model_delete(model$name)
            expect_identical(mm$save_model(model), "New model loaded into ModelManage.")
            expect_gt(length(mm$model_list()), 0)
            expect_is(mm$model_get(model$name), "Model")
            expect_equal(mm$model_delete(model$name), 204)
          }
)
test_that("test_schema",
          {
            schema <- Schema(name = "array-double",
                             source = paste(readLines("./fastscore/library/schemas/array-double.avsc"), collapse="\n"),
                             model_manage = mm)
            expect_is(mm$schema_get(schema$name), "Schema")
            mm$schema_delete(schema$name)
            expect_identical(mm$save_schema(schema), "New schema loaded into ModelManage.")
            expect_gt(length(mm$schema_list()), 0)
            expect_equal(mm$schema_delete(schema$name), 204)
          }
)
