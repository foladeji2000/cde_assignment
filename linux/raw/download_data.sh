#!/bin/bash

URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"

OUTPUT_DIR="/Users/ayodeji/Desktop/cde_assignment/linux/raw"

mkdir -p "$OUTPUT_DIR"

curl -L "$URL" -o "$OUTPUT_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv"

echo "Download complete: $OUTPUT_DIR"
