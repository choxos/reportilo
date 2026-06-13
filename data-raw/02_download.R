#!/usr/bin/env Rscript
# 02_download.R
# Download every file in the manifest with curl (parallel, resumable). Failures
# are recorded, never fatal. Re-running skips files already present.

suppressPackageStartupMessages({
  library(curl)
  library(digest)
})

here <- function(...) file.path("data-raw", ...)
man <- read.csv(here("download_manifest.csv"), stringsAsFactors = FALSE)

UA <- "Mozilla/5.0 (compatible; reportilo/0.1; +https://github.com/choxos/reportilo)"

# Ensure destination directories exist.
for (dir in unique(dirname(man$local_path))) {
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
}

# Only fetch files not already downloaded (non-empty on disk).
have <- file.exists(man$local_path) & file.size(man$local_path) > 0
todo <- which(!have)
cat(sprintf("Files: %d total, %d present, %d to download\n",
  nrow(man), sum(have), length(todo)))

if (length(todo)) {
  res <- multi_download(
    urls = man$source_url[todo],
    destfiles = man$local_path[todo],
    resume = FALSE,
    progress = TRUE,
    timeout = 180,
    useragent = UA
  )
  man$status[todo] <- ifelse(res$success %in% TRUE, "ok",
    ifelse(is.na(res$status_code), "dead", paste0("http_", res$status_code)))
  man$http_status <- NA_integer_
  man$http_status[todo] <- res$status_code
  man$content_type <- NA_character_
  if (!is.null(res$type)) man$content_type[todo] <- res$type
}

# Finalize status/size/sha for every row from what is on disk.
ok <- file.exists(man$local_path) & file.size(man$local_path) > 0
man$status[ok & man$status == "pending"] <- "ok"
man$bytes <- ifelse(ok, file.size(man$local_path), 0L)
man$sha256 <- NA_character_
for (i in which(ok)) man$sha256[i] <- digest(file = man$local_path[i], algo = "sha256")
man$status[!ok & man$status == "pending"] <- "missing"

write.csv(man, here("download_manifest.csv"), row.names = FALSE)
cat("\nStatus tally:\n"); print(table(man$status))
cat(sprintf("Downloaded bytes: %.1f MB\n", sum(man$bytes, na.rm = TRUE) / 1e6))
