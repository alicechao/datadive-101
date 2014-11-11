## ufo_sightings.R
## https://github.com/johnmyleswhite/ML_for_Hackers
##

setwd("~/datadives/datadive101/")

pkg <- c("dplyr")
new.pkg <- pkg[! (pkg %in% installed.packages())]
if (length(new.pkg)) {
  install.packages(new.pkg)
}

library(dplyr)

dataset <- "./ufo_awesome.tsv"
if (! file.exists(destfile)) {
  # shasum: 39cfc99c9814d8806526a1adeaf3c582e47b0f27
  file.url <- "https://raw.githubusercontent.com/johnmyleswhite/ML_for_Hackers/master/01-Introduction/data/ufo/ufo_awesome.tsv"
  download.file(file.url, destfile = dataset, method = "curl")
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

ufo <- tbl_df(read.delim(dataset, sep = "\t", header = FALSE,
                         stringsAsFactors = FALSE, na.strings = ""))
names(ufo) <- c("DateOccurred", "DateReported", "Location", "ShortDescription",
                "Duration", "LongDescription")
head(ufo, 3)
# DateOccurred DateReported              Location ShortDescription Duration
# 1     19951009     19951009         Iowa City, IA               NA       NA
# 2     19951010     19951011         Milwaukee, WI               NA   2 min.
# 3     19950101     19950103           Shelton, WA               NA       NA
# Variables not shown: LongDescription (chr)

# x %>% f(y) -> f(x, y)
ufo <- ufo %>%
  mutate(DateOccurred = as.Date(DateOccurred, format = "%Y%m%d"),
         DateReported = as.Date(DateReported, format = "%Y%m%d"))
# Error in strptime(x, format, tz = "GMT") : input string is too long
# Why? Some entries in the Date* columns are too long to match the format string

table(nchar(ufo$DateOccurred) != 8 |
        nchar(ufo$DateReported) != 8)
# FALSE  TRUE 
# 61139   731

# List dates that are not 8 characters long
head(ufo[ # row
  which(nchar(ufo$DateOccurred) != 8 | 
          nchar(ufo$DateReported) != 8)
  , 1]) # column

# Construct a vector of TRUE and FALSE
good.rows <- ifelse(
  nchar(ufo$DateOccurred) != 8 | nchar(ufo$DateReported) != 8,
  FALSE, TRUE # returns FALSE if != 8
  )
table(good.rows)
# FALSE  TRUE
# 731 61139

ufo <- ufo[good.rows, ]
rm(good.rows)

ufo <- ufo %>%
  mutate(DateOccurred = as.Date(DateOccurred, format = "%Y%m%d"),
         DateReported = as.Date(DateReported, format = "%Y%m%d"))
head(ufo, 3)
# DateOccurred DateReported       Location ShortDescription Duration
# 1   1995-10-09   1995-10-09  Iowa City, IA               NA       NA
# 2   1995-10-10   1995-10-11  Milwaukee, WI               NA   2 min.
# 3   1995-01-01   1995-01-03    Shelton, WA               NA       NA
# Variables not shown: LongDescription (chr)
