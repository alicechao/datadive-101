## ufo_sightings.R
## Copyright (C) 2012 Drew Conway <drew.conway@nyu.edu>
## Copyright (C) 2014 Eugene Teo <eugeneteo@gmail.com>
##
## https://github.com/johnmyleswhite/ML_for_Hackers
## http://www.meetup.com/DataKind-SG/events/214159532/
##
## All source code is copyright (c) 2012-2014, under the Simplified BSD License.
## For more information on FreeBSD see: http://www.opensource.org/licenses/bsd-license.php
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

# We only want China incidents of UFO sightings
get.location <- function(loc) {
  # Remove leading whitespace
  loc <- gsub("^ ", "", loc)
  
  split.location <- tryCatch(
    strsplit(loc, ",")[[1]], error = function(e) return (c(NA, NA))
    ) # [1] "Nanjing (China)"
  
  split.location <- tryCatch(
    strsplit(split.location, " ")[[1]], error = function(e) return (c(NA, NA))
    ) # [1] "Nanjing" "(China)"
  
  clean.location <- gsub("^\\(", "", split.location)
  clean.location <- gsub(")$", "", clean.location)
  
  if (length(clean.location) == 2) {
    return (clean.location)
  } else {
    return (c(NA, NA))
  }
}

province <- lapply(ufo$Location, get.location)
location.matrix <- do.call(rbind, province)
ufo <- ufo %>%
  mutate(Province = location.matrix[, 1], Country = location.matrix[, 2],
         stringsAsFactors = FALSE) %>%
  select(-Location, -Duration) %>%#), -LongDescription) %>%
  # Exclude "South China, ME" as it is not in China
  filter(Country == "China" & Province != "South") %>%
  mutate(Mean = (DateReported - DateOccurred)) %>%
  filter(Mean >= 0)

# Display the number of sightings in each province, and the average number of
# days the reporters took to report an incident
ufo %>%
  group_by(Province) %>%
  summarise(Sightings = n(), Avg.Reporting = mean(Mean)) %>%
  #arrange(desc(Avg.Reporting))
  arrange(desc(Sightings))

# The same as above except that we group by the provinces and the short
# description
ufo %>%
  group_by(Province, ShortDescription) %>%
  summarise(Avg.Reporting = mean(Mean), Sightings = n()) %>%
  arrange(desc(Avg.Reporting))

# Look at China broadly, group by short descriptions
ufo %>%
  group_by(ShortDescription) %>%
  summarise(Avg.Reporting = mean(Mean), Sightings = n()) %>%
  arrange(desc(Avg.Reporting))

# Sort sightings by DateOccurred in descending order
oldest <- ufo %>%
  arrange(DateOccurred)
# Display the description of the second oldest sighting
print(oldest$LongDescription[2])

summary(ufo$DateOccurred)
#         Min.      1st Qu.       Median         Mean      3rd Qu.         Max. 
# "1988-10-05" "2004-07-27" "2006-11-23" "2005-07-07" "2008-12-04" "2010-07-10"
