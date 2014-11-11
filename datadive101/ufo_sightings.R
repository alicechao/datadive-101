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

# $ file ufo_awesome.tsv
# ufo_awesome.tsv: ASCII English text, with very long lines
#
# $ wc -l ufo_awesome.tsv
# 61393 ufo_awesome.tsv
#
# $ head -1 ufo_awesome.tsv
# 19951009  19951009	 Iowa City, IA			Man repts. witnessing &quot;flash,
#   followed by a classic UFO, w/ a tailfin at back.&quot; Red color on top half
#   of tailfin. Became triangular.
#
# $ head -1 ufo_awesome.tsv | od -c | grep '\\t'
# 0000000    1   9   9   5   1   0   0   9  \t   1   9   9   5   1   0   0
# 0000020    9  \t       I   o   w   a       C   i   t   y   ,       I   A
# 0000040   \t  \t  \t   M   a   n       r   e   p   t   s   .       w   i
