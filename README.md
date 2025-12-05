# Project Overview

This project establishes a comprehensive system for processing cryptocurrency transaction data, encompassing data collection, transformation, analysis, and aggregation. The main components include:

- **.devcontainer**: Manages rapid development environments for team members.
- **.github**: Configures and manages CI/CD pipelines for testing and deployment across environments.
- **docker/**: Handles deployment environments using Docker.
- **orchestration/**: Orchestrates data processing workflows with Airflow/DAGs.
- **scripts/**: Contains scripts for data collection and ingestion.
- **source_data/**: Stores source input data files.
- **transform/**: Performs data transformation, analysis, and testing using dbt.
- **ouput/**: Stores raw data retrieved from external sources, such as APIs or third-party providers.

## Project Directory Structure

```
remitano_de_test__vypham/
├── ARCHITECTURE.md
├── README.md
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── requirements.txt
├── .github/
│   └── workflows/
│       ├── github_ci.yml
├── docker/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── requirements.txt
├── logs/
├── orchestration/
│   ├── orchestration_docs.md
│   └── dags/
│       ├── config/
│       │   └── dependence_tasks.yml
│       ├── data_pipeline/
│       │   ├── load/
│       │   └── transform/
│       └── utils/
├── ouput/
│   └── raw_rates/
│       └── rates.csv
├── scripts/
│   ├── get_coin_rate.py
│   └── get_transactions_summary.py
├── source_data/
│   ├── transactions_summary.json
│   ├── transactions.csv
│   └── users.csv
├── transform/
│   ├── dbt_project.yml
│   ├── analyses/
│   ├── macros/
│   ├── models/
│   │   ├── example/
│   │   │   ├── my_first_dbt_model.sql
│   │   │   ├── my_second_dbt_model.sql
│   │   │   └── schema.yml
│   │   ├── int/
│   │   │   ├── silver_int_schema.yml
│   │   │   └── finance/
│   │   │       ├── silver_int_transactions.sql
│   │   │       └── silver_int_user_kyc_history.sql
│   │   ├── marts/
│   │   │   ├── gold_marts_schema.yml
│   │   │   └── finance/
│   │   │       ├── gold_marts_transactions_completed_kyc.sql
│   │   │       └── gold_marts_transactions_volume.sql
│   │   └── staging/
│   │       ├── src_raw_bronze.yml
│   │       ├── finance/
│   │       │   ├── bronze_stg_transactions.sql
│   │       │   └── bronze_stg_users.sql
│   │       └── other_source/
│   │           └── bronze_stg_rates.sql
│   ├── seeds/
│   ├── snapshots/
│   └── tests/
│       └── custom_test/
```


