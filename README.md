# CoreDataEngineers Bash ETL

## Run the ETL

```bash
chmod +x etl_pipeline.sh move_json_and_csv.sh install_daily_cron.sh
./etl_pipeline.sh
```

The script reads the source URL from `DATA_URL`; it uses the supplied Stats NZ
URL by default. It downloads the source to `raw/`, writes selected and renamed
fields to `Transformed/2023_year_finance.csv`, and copies that file to `Gold/`.
It prints a confirmation after every layer is saved.

## Schedule it daily at midnight

Run this once:

```bash
./install_daily_cron.sh
```

This installs the following cron schedule and appends output to `etl_cron.log`:

```cron
0 0 * * * /bin/bash /absolute/path/to/etl_pipeline.sh >> /absolute/path/to/etl_cron.log 2>&1 # CoreDataEngineers daily ETL
```

`0 0 * * *` means minute 0, hour 0, every day. Verify with `crontab -l`.
Cron uses a minimal environment; the script uses absolute paths and invokes
`/bin/bash` explicitly to avoid common cron path issues.

## Move CSV and JSON files

```bash
./move_json_and_csv.sh /path/to/source /path/to/json_and_CSV
```

With no arguments it moves one or more `.csv` and `.json` files from
`source_files/` to `json_and_CSV/`. Matching is case-insensitive and filenames
with spaces are handled safely.
