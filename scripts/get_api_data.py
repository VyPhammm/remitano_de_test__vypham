import requests
import time
from datetime import datetime, timedelta
import json
import pandas as pd

def get_coin_price_1h(
        base_aset="BTC",
        quote_aset="USDT", 
        interval="1h", 
        start_date=None, 
        end_date=None
    ):
    """
    get coin's price from start_date to end_date, candle: 1H
    output:
        ["open_time", "close_time", "open", "high", "low", "close"]
    """
    url = "https://api.binance.com/api/v3/klines"
    limit = 1000
    result = []
    symbol= f"{base_aset}{quote_aset}"
    start_dt = datetime.fromisoformat(start_date)
    end_dt = datetime.fromisoformat(end_date)

    # If start_date = end_date, increase end_date by 1 day
    if start_dt.date() == end_dt.date():
        end_dt += timedelta(days=1)

    start_ts = int(start_dt.timestamp() * 1000)
    end_ts = int(end_dt.timestamp() * 1000)

    while start_ts < end_ts:
        params = {
            "symbol": symbol,
            "interval": interval,
            "startTime": start_ts,
            "endTime": end_ts,
            "limit": limit
        }

        resp = requests.get(url, params=params)
        data = resp.json()

        if isinstance(data, dict):
            print(f"Error fetching {symbol}: {data}")
            break

        if not data:
            break

        for row in data:
            # ["open_time", "close_time", "open", "high", "low", "close", "volume"]
            record = {
                "open_time": datetime.fromtimestamp(int(row[0])/1000).isoformat(),
                "close_time": datetime.fromtimestamp(int(row[6])/1000).isoformat(),
                "base_aset": base_aset,
                "quote_aset": quote_aset,
                "symbol": symbol,
                "open": row[1],
                "high": row[2],
                "low": row[3],
                "close": row[4]
            }
            result.append(record)

        # Update start_ts for the next batch
        start_ts = int(data[-1][6]) + 1  # close_time + 1 ms
        time.sleep(0.1)

    return result

data_path = r"../data/transactions_summary.json"

with open(data_path, "r") as f:
    coins = json.load(f)

all_prices = []

# Lặp qua từng coin
for coin_info in coins:
    coin = coin_info["coin"]
    min_time = coin_info["min_time"]
    max_time = coin_info["max_time"]

    print(f"Fetching price for {coin} from {min_time} to {max_time} ...")
    prices = get_coin_price_1h(base_aset=coin, quote_aset="USDT", start_date=min_time, end_date=max_time)
    all_prices.extend(prices)

# Chuyển sang DataFrame và xuất CSV
df = pd.DataFrame(all_prices)
df.to_csv("../data/coin_prices_1h.csv", index=False)
print("Done! CSV saved to ../data/coin_prices_1h.csv")