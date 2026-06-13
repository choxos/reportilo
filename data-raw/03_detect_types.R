#!/usr/bin/env Rscript
# 03_detect_types.R
# Sniff magic bytes to confirm the real file type and catch HTML interstitials
# (paywalls/login pages returned with a .pdf or .docx URL). Optionally convert
# legacy .doc (OLE2) to .docx with LibreOffice when `soffice` is available.

here <- function(...) file.path("data-raw", ...)
man <- read.csv(here("download_manifest.csv"), stringsAsFactors = FALSE)

raw_to_text <- function(raw) {
  # drop embedded nuls, then coerce to plain ASCII so tolower/grepl never hit
  # an invalid multibyte sequence on binary input
  iconv(rawToChar(raw[raw != as.raw(0)]), to = "ASCII", sub = "")
}

sniff <- function(path) {
  if (!file.exists(path) || file.size(path) == 0) return(NA_character_)
  raw <- readBin(path, "raw", n = 2048)
  if (length(raw) >= 4 && all(raw[1:4] == charToRaw("%PDF"))) return("pdf")
  if (length(raw) >= 4 && all(raw[1:4] == as.raw(c(0x50, 0x4B, 0x03, 0x04)))) {
    # zip container: inspect the central directory for Office parts
    entries <- tryCatch(utils::unzip(path, list = TRUE)$Name, error = function(e) character(0))
    if (any(grepl("word/document.xml", entries, fixed = TRUE))) return("docx")
    if (any(grepl("xl/workbook.xml", entries, fixed = TRUE))) return("xlsx")
    return("zip")
  }
  if (length(raw) >= 8 &&
    all(raw[1:8] == as.raw(c(0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1)))) {
    return("doc")
  }
  head_txt <- tolower(raw_to_text(raw))
  if (grepl("<!doctype html|<html", head_txt)) return("html")
  "unknown"
}

man$detected <- vapply(man$local_path, sniff, character(1))
man$type_mismatch <- !is.na(man$detected) &
  man$detected %in% c("html", "unknown") &
  man$ext %in% c("pdf", "docx", "doc")

# Optional .doc -> .docx conversion via LibreOffice.
soffice <- Sys.which("soffice")
if (nzchar(soffice)) {
  doc_rows <- which(man$detected == "doc")
  for (i in doc_rows) {
    outdir <- dirname(man$local_path[i])
    ok <- tryCatch(
      {
        system2(soffice, c("--headless", "--convert-to", "docx", "--outdir",
          shQuote(outdir), shQuote(man$local_path[i])), stdout = TRUE, stderr = TRUE)
        TRUE
      },
      error = function(e) FALSE
    )
    newp <- sub("\\.docx?$", ".docx", man$local_path[i])
    if (ok && file.exists(newp)) {
      man$local_path[i] <- newp
      man$ext[i] <- "docx"
      man$detected[i] <- "docx"
    }
  }
} else {
  message("soffice not found; legacy .doc files will be routed to overrides.")
}

write.csv(man, here("download_manifest.csv"), row.names = FALSE)
cat("Detected types:\n"); print(table(man$detected, useNA = "ifany"))
cat("type_mismatch (unusable):", sum(man$type_mismatch, na.rm = TRUE), "\n")
