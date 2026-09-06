# CoreDataEngineers Bash ETL

## Run the ETL

```bash
cd /Users/ayodeji/Desktop/cde_assignment/linux
chmod +x etl_pipeline.sh move_json_and_csv.sh install_daily_cron.sh
./etl_pipeline.sh
```

The URL is stored in the `URL` variable at the top of the script. The script
downloads the source to `raw/`, writes selected and renamed fields to
`Transformed/2023_year_finance.csv`, and copies that file to `Gold/`.

## Schedule it daily at midnight

Run this once:

```bash
./install_daily_cron.sh
```

This installs the following cron schedule and appends output to `etl_cron.log`:

```cron
0 0 * * * /bin/bash /Users/ayodeji/Desktop/cde_assignment/linux/etl_pipeline.sh >> /Users/ayodeji/Desktop/cde_assignment/linux/etl_cron.log 2>&1
```

`0 0 * * *` means minute 0, hour 0, every day. Verify with `crontab -l`.
Cron uses a minimal environment; the script uses absolute paths and invokes
`/bin/bash` explicitly to avoid common cron path issues.

## Move CSV and JSON files

```bash
./move_json_and_csv.sh my_files json_and_CSV
```

The first folder is the source and the second folder is the destination. This
moves one or more `.csv` and `.json` files from `my_files/` to `json_and_CSV/`.
