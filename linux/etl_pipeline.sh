#!/bin/bash

# This script downloads a CSV file, changes the columns, and saves it in Gold.

# Go to the folder where this script is saved.
cd "$(dirname "$0")"

# The URL is stored in a variable so it can be used in the download command.
export URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"

# Create the folders if they do not already exist.
mkdir -p raw
mkdir -p Transformed
mkdir -p Gold

echo "Starting the ETL process..."

# ---------------- EXTRACT ----------------
echo "Downloading the CSV file..."
curl -o raw/annual_enterprise_survey.csv "$URL"

# Check that the downloaded file exists.
if [ -f raw/annual_enterprise_survey.csv ]; then
    echo "The file was saved in the raw folder."
else
    echo "Download failed."
    exit 1
fi

# ---------------- TRANSFORM ----------------
# In this CSV: Year is column 1, Units is column 5,
# Variable_code is column 6, and Value is column 9.
# The first line creates the new column names. The remaining lines select data.
echo "Transforming the CSV file..."
awk -F',' 'BEGIN {OFS=","}
NR==1 {print "year", "Value", "Units", "variable_code"}
NR>1 {print $1, $9, $5, $6}' raw/annual_enterprise_survey.csv > Transformed/2023_year_finance.csv

if [ -f Transformed/2023_year_finance.csv ]; then
    echo "The transformed file was saved in the Transformed folder."
else
    echo "Transformation failed."
    exit 1
fi

# ---------------- LOAD ----------------
# Copy the transformed file into the Gold folder.
echo "Loading the transformed file into Gold..."
cp Transformed/2023_year_finance.csv Gold/2023_year_finance.csv

if [ -f Gold/2023_year_finance.csv ]; then
    echo "The file was saved in the Gold folder."
    echo "ETL process completed."
else
    echo "Load failed."
fi
