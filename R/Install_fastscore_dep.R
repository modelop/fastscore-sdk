r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)
install.packages(c("curl", "jsonlite", "mime", "openssl", "R6", "yaml", "httr"))
