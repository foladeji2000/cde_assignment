#!/usr/bin/env bash
# Install one idempotent cron entry for etl_pipeline.sh at 12:00 AM daily.
# Run this once as the account that should own the scheduled job.

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly ETL_SCRIPT="$SCRIPT_DIR/etl_pipeline.sh"
readonly LOG_FILE="$SCRIPT_DIR/etl_cron.log"
readonly CRON_MARKER="# CoreDataEngineers daily ETL"
readonly CRON_LINE="0 0 * * * /bin/bash $ETL_SCRIPT >> $LOG_FILE 2>&1 $CRON_MARKER"

command -v crontab >/dev/null 2>&1 || {
  printf 'ERROR: crontab is not installed or not in PATH.\n' >&2
  exit 1
}
[[ -x "$ETL_SCRIPT" ]] || {
  printf 'ERROR: ETL script must be executable: %s\n' "$ETL_SCRIPT" >&2
  exit 1
}

current_crontab="$(crontab -l 2>/dev/null || true)"
if printf '%s\n' "$current_crontab" | grep -Fq "$CRON_MARKER"; then
  printf 'Daily ETL cron entry already exists.\n'
else
  { printf '%s\n' "$current_crontab"; printf '%s\n' "$CRON_LINE"; } | crontab -
  printf 'Installed daily ETL cron entry for 12:00 AM.\n'
fi
