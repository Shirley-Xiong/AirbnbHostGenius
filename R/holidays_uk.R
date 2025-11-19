# R/holidays_uk.R
# Minimal UK holiday provider using GOV.UK API + bizdays, with caching and offline fallback.

suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
  library(bizdays)
}).uk_cache_env <- new.env(parent = emptyenv()).uk_cache_env$calendar_name <- "UK_EAW"

# 1) Fetch UK bank holidays (England & Wales by default) with cache and offline fallback
get_uk_bank_holidays <- function(region = c("england-and-wales", "scotland", "northern-ireland"),
                                 use_cache = TRUE) {
  region <- match.arg(region)
  key <- paste0("hol_", region)
  if (use_cache && !is.null(.uk_cache_env[[key]])) return(.uk_cache_env[[key]])
  
  dates <- try({
    url <- "https://www.gov.uk/bank-holidays.json"
    txt <- httr::GET(url, timeout(10)) |> content(as = "text", encoding = "UTF-8")
    j <- jsonlite::fromJSON(txt)
    ev <- j[[region]][["events"]]
    as.Date(ev$date)
  }, silent = TRUE)
  
  # Offline fallback if API fails
  if (inherits(dates, "try-error")) {
    message("GOV.UK API unavailable; using minimal fallback dates.")
    dates <- as.Date(c(
      "2025-01-01","2025-04-18","2025-04-21","2025-05-05","2025-05-26","2025-08-25",
      "2025-12-25","2025-12-26"
    ))
  }.uk_cache_env[[key]] <- dates
  dates
}

# 2) Create or get a bizdays calendar
uk_calendar_name <- function(region = c("england-and-wales","scotland","northern-ireland")) {
  region <- match.arg(region)
  nm <- paste0("UK_", toupper(substr(region, 1, 3)))
  if (!(nm %in% bizdays::calendars())) {
    hol <- get_uk_bank_holidays(region)
    bizdays::create.calendar(
      name        = nm,
      holidays    = hol,
      weekdays    = c("saturday","sunday"),
      adjust.from = "next",
      adjust.to   = "previous"
    )
  }
  nm
}

# 3) Helpers your app can call
is_holiday_uk <- function(dates, region = "england-and-wales") {
  hol <- get_uk_bank_holidays(region)
  as.Date(dates) %in% hol
}

is_business_day_uk <- function(dates, region = "england-and-wales") {
  cal <- uk_calendar_name(region)
  bizdays::is.bizday(as.Date(dates), cal)
}

add_business_days_uk <- function(date, n, region = "england-and-wales") {
  cal <- uk_calendar_name(region)
  bizdays::add.bizdays(as.Date(date), n, cal)
}

# Optional alias if your app expects is_holiday()
is_holiday <- function(dates, region = "england-and-wales") is_holiday_uk(dates, region)