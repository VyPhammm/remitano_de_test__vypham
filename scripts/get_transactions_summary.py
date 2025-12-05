import pandas as pd
import json
import logging

FILE_PATH = r"../source_data/transactions.csv"
OUTPUT_PATH = r"../source_data/transactions_summary.json"

def extract_data_coin_json():
    """
    extract: coin, min_date, max_date from transactions data and save to json file
    """
    df = pd.read_csv(FILE_PATH, parse_dates=["created_at"])
    df["created_date"] = df["created_at"].dt.date

    # group currency columns into one
    df_melt = pd.melt(
        df,
        id_vars=["created_date"],
        value_vars=["source_currency", "destination_currency"],
        value_name="coin"
    )

    summary = (
        df_melt.groupby("coin")["created_date"]
        .agg(["min", "max"])
        .reset_index()
        .rename(columns={"min": "min_time", "max": "max_time"})
    )

    summary["min_time"] = summary["min_time"].astype(str)
    summary["max_time"] = summary["max_time"].astype(str)

    result = summary.to_dict(orient="records")

    with open(OUTPUT_PATH, "w") as f:
        json.dump(result, f, indent=2)
    logging.warning(f"Extracted data saved to {OUTPUT_PATH}")
    return result

if __name__ == "__main__":
    extract_data_coin_json()