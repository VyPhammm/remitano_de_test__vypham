import pandas as pd
import json

df = pd.read_csv(r"../data/transactions.csv", parse_dates=["created_at"])

df["created_date"] = df["created_at"].dt.date

result = []
for coin, group in df.groupby("destination_currency"):
    result.append({
        "coin": coin,
        "min_time": str(group["created_date"].min()),
        "max_time": str(group["created_date"].max())
    })

with open("../data/transactions_summary.json", "w") as f:
    json.dump(result, f, indent=2)