import pandas as pd
import json

FILE_PATH = r"../source_data/transactions.csv"
OUTPUT_PATH = r"../data/transactions_summary.json"

def extract_data_coin_json():
    """
    extract: coin, min_date, max_date from transactions data and save to json file
    """
    df = pd.read_csv(FILE_PATH, parse_dates=["created_at"])
    df["created_date"] = df["created_at"].dt.date

    result = []
    for coin, group in df.groupby("source_currency"):
        result.append({
            "coin": coin,
            "min_time": str(group["created_date"].min()),
            "max_time": str(group["created_date"].max())
        })
    for coin, group in df.groupby("destination_currency"):
        result.append({
            "coin": coin,
            "min_time": str(group["created_date"].min()),
            "max_time": str(group["created_date"].max())
        })

    with open(OUTPUT_PATH, "w") as f:
        json.dump(result, f, indent=2)