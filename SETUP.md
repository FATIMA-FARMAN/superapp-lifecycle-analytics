# 🛠️ Setup Guide

## Prerequisites

- Python 3.8+
- pip or conda

## Installation Steps

### 1. Install dbt-duckdb

```bash
pip install dbt-duckdb
```

### 2. Configure dbt Profile

Copy the profile template:

```bash
mkdir -p ~/.dbt
cp profiles_template/profiles.yml ~/.dbt/profiles.yml
```

### 3. Install dbt Packages

```bash
dbt deps
```

### 4. Load Seed Data

Place your CSV files in the `seeds/` directory:
- `users.csv`
- `transactions.csv`
- `events.csv`

Then load them:

```bash
dbt seed
```

### 5. Run the Pipeline

```bash
# Run all models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## Troubleshooting

### DuckDB Lock Error
If you see "database is locked", ensure no other process is using dev.duckdb:
```bash
rm dev.duckdb
dbt run
```

### Missing Seeds
Ensure CSV files are in `seeds/` folder and referenced in `dbt_project.yml`

## Data Refresh

This project uses full-refresh strategy. For incremental updates:
```bash
dbt run --full-refresh
```
