context("Connect Test")

setwd("/Users/nanshi/Documents/GitHub")
connect <- Connect(proxy_prefix="https://localhost:8000")

test_that("test_connect",
          {
            expect_is(connect, "Connect")
            expect_true(connect$check_health())
          }
)

#pneumo not tested

test_that("test_lookup",
          {
            expect_error(connect$lookup("engine-1"))
            expect_is(connect$lookup("engine"), "Engine")
            expect_is(connect$lookup("model-manage"), "ModelManage")
          }
)
test_that("test_get",
          {
            expect_error(connect$get("engine"))
            expect_is(connect$get("connect"), "Connect")
            expect_is(connect$get("engine-1"), "Engine")
            expect_is(connect$get("model-manage-1"), "ModelManage")
          }
)

#prefer not tested

#Need to check yaml.load() or fromJSON function
test_that("test_configure",
          {
            config <- paste(readLines("./fastscore/config.yaml"), collapse="\n")
            expect_true(connect$configure(config))
            Sys.sleep(3)
          }
)
test_that("test_get_configure",
          {
            expect_type(connect$get_config("db"), "list")
          }
)
test_that("test_fleet",
          {
            expect_error(connect$fleet(3))
            expect_identical(connect$fleet()[[1]]$release, "1.9")
          }
)

#dump not tested

#Connect.make_instance?
#Connect.load?
