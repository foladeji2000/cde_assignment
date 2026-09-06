#!/bin/bash

# This script adds a cron job that runs the ETL script every day at midnight.

# Find the folder where this script is saved.
SCRIPT_FOLDER="$(cd "$(dirname "$0")" && pwd)"

# Cron format: minute hour day-of-month month day-of-week command
# 0 0 means 12:00 AM every day.
CRON_JOB="0 0 * * * /bin/bash $SCRIPT_FOLDER/etl_pipeline.sh >> $SCRIPT_FOLDER/etl_cron.log 2>&1"

# Add the cron job to the current user's crontab.
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Cron job added. The ETL script will run every day at 12:00 AM."
