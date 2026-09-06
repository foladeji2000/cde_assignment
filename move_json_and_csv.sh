#!/usr/bin/env bash
# Move every .csv and .json file from a source folder to json_and_CSV.
# Usage: ./move_json_and_csv.sh [source_folder] [destination_folder]
# Defaults: ./source_files and ./json_and_CSV (relative to this script).

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_DIR="${1:-$SCRIPT_DIR/source_files}"
readonly DESTINATION_DIR="${2:-$SCRIPT_DIR/json_and_CSV}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

if [[ ! -d "$SOURCE_DIR" ]]; then
  log "ERROR: Source folder does not exist: $SOURCE_DIR"
  exit 1
fi

mkdir -p "$DESTINATION_DIR"
log "Moving CSV and JSON files from $SOURCE_DIR to $DESTINATION_DIR"

# find -print0 / read -d handles filenames containing spaces safely. -maxdepth
# limits the operation to the source folder itself (not its subdirectories).
count=0
while IFS= read -r -d '' file; do
  mv "$file" "$DESTINATION_DIR/"
  log "Moved: $(basename -- "$file")"
  ((count += 1))
done < <(find "$SOURCE_DIR" -maxdepth 1 -type f \( -iname '*.csv' -o -iname '*.json' \) -print0)

log "Completed: moved $count CSV/JSON file(s)."
