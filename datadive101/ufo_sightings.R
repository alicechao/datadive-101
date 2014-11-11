## ufo_sightings.R
## https://github.com/johnmyleswhite/ML_for_Hackers
##

setwd("~/datadives/datadive101/")

pkg <- c("dplyr")
new.pkg <- pkg[! (pkg %in% installed.packages())]
if (length(new.pkg)) {
  install.packages(new.pkg)
}

destfile <- "./ufo_awesome.tsv"
if (! file.exists(destfile)) {
  # shasum: 39cfc99c9814d8806526a1adeaf3c582e47b0f27
  file.url <- "https://raw.githubusercontent.com/johnmyleswhite/ML_for_Hackers/master/01-Introduction/data/ufo/ufo_awesome.tsv"
  download.file(file.url, destfile = destfile, method = "curl")
}
