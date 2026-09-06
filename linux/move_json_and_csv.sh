#!/bin/bash

# This script moves all CSV and JSON files from one folder to another folder.
# Usage: ./move_json_and_csv.sh source_folder destination_folder

SOURCE_FOLDER="$1"
DESTINATION_FOLDER="$2"

# Create the destination folder if it does not exist.
mkdir -p "$DESTINATION_FOLDER"

echo "Moving CSV files..."
for file in "$SOURCE_FOLDER"/*.csv
do
    # Only move the file if a CSV file was found.
    if [ -f "$file" ]; then
        mv "$file" "$DESTINATION_FOLDER"
        echo "Moved: $file"
    fi
done

echo "Moving JSON files..."
for file in "$SOURCE_FOLDER"/*.json
do
    # Only move the file if a JSON file was found.
    if [ -f "$file" ]; then
        mv "$file" "$DESTINATION_FOLDER"
        echo "Moved: $file"
    fi
done

echo "Finished moving CSV and JSON files."
