#!/usr/bin/env bash
#
# Simple daily ETL pipeline for the Annual Enterprise Survey CSV.
# Run from this project's directory, or set PIPELINE_ROOT to another location.
# DATA_URL is deliberately an environment variable so the data source can be
# changed without editing this script.

set -euo pipefail

readonly PIPELINE_ROOT="${PIPELINE_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)}"
readonly DATA_URL="${DATA_URL:-https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv}"
readonly RAW_DIR="$PIPELINE_ROOT/raw"
readonly TRANSFORMED_DIR="$PIPELINE_ROOT/Transformed"
readonly GOLD_DIR="$PIPELINE_ROOT/Gold"
readonly RAW_FILE="$RAW_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv"
readonly TRANSFORMED_FILE="$TRANSFORMED_DIR/2023_year_finance.csv"
readonly GOLD_FILE="$GOLD_DIR/2023_year_finance.csv"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    log "ERROR: Required command '$1' was not found."
    exit 1
  }
}

log "Starting ETL pipeline."
require_command curl
require_command awk
mkdir -p "$RAW_DIR" "$TRANSFORMED_DIR" "$GOLD_DIR"

# EXTRACT: download into a temporary file first so a failed download never
# replaces a previously successful raw data file.
log "EXTRACT: Downloading CSV from DATA_URL."
raw_tmp="$RAW_FILE.tmp"
trap 'rm -f "$raw_tmp" "$TRANSFORMED_FILE.tmp"' EXIT
curl --fail --location --retry 3 --output "$raw_tmp" "$DATA_URL"
mv "$raw_tmp" "$RAW_FILE"

if [[ -s "$RAW_FILE" ]]; then
  log "EXTRACT complete: file saved in raw/: $RAW_FILE"
else
  log "ERROR: Download did not create a non-empty file in raw/."
  exit 1
fi

# TRANSFORM: locate fields by their header positions, rename Variable_code in
# the output header, and retain only year, Value, Units, and variable_code.
# The supplied source has plain CSV fields, so awk's comma field separator is
# appropriate here.
log "TRANSFORM: Renaming Variable_code and selecting required columns."
awk -F',' '
  NR == 1 {
    for (i = 1; i <= NF; i++) {
      if ($i == "Year") year = i
      if ($i == "Value") value = i
      if ($i == "Units") units = i
      if ($i == "Variable_code") variable_code = i
    }
    if (!year || !value || !units || !variable_code) {
      print "ERROR: Expected headers (Year, Value, Units, Variable_code) were not found." > "/dev/stderr"
      exit 2
    }
    print "year,Value,Units,variable_code"
    next
  }
  { print $year "," $value "," $units "," $variable_code }
' "$RAW_FILE" > "$TRANSFORMED_FILE.tmp"
mv "$TRANSFORMED_FILE.tmp" "$TRANSFORMED_FILE"

if [[ -s "$TRANSFORMED_FILE" ]]; then
  log "TRANSFORM complete: file saved in Transformed/: $TRANSFORMED_FILE"
else
  log "ERROR: Transformation did not create a non-empty file in Transformed/."
  exit 1
fi

# LOAD: copy the transformed dataset into the Gold data layer.
log "LOAD: Copying transformed CSV to Gold/."
cp "$TRANSFORMED_FILE" "$GOLD_FILE"

if [[ -s "$GOLD_FILE" ]]; then
  log "LOAD complete: file saved in Gold/: $GOLD_FILE"
  log "ETL pipeline finished successfully."
else
  log "ERROR: File was not saved in Gold/."
  exit 1
fi
