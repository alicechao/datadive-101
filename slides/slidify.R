setwd("~/datadive-101/")

# install.packages("devtools")
pkg <- c("slidify", "slidifyLibraries")
new.pkg <- pkg[! (pkg %in% installed.packages())]
if (length(new.pkg)) {
  library(devtools)
  install_github(new.pkg, "ramnathv", ref = "dev")
}

library(slidify)
library(slidifyLibraries)

author("datadive-101")
slidify("index.Rmd")
browseURL("index.html")
