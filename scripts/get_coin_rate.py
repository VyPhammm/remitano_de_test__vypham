import requests
import time
from datetime import datetime, timedelta
import json
import pandas as pd
import logging

def get_coin_price_1h(
        base_currency="BTC",
        quote_currency="USDT", 
        interval="1h", 
        start_date=None, 
        end_date=None
    ):
    """
    get coin's price from start_date to end_date, candle: 1H
    output data with column names:
        ["open_time", "close_time", "base_currency", "quote_currency", "symbol", "open", "high", "low", "close"]
    """
    url = "https://api.binance.com/api/v3/klines"
    limit = 1000
    result = []
    symbol= f"{base_currency}{quote_currency}"
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
            logging.warning(f"Error fetching {symbol}: {data}")
            break

        if not data:
            break

        for row in data:
            # ["open_time", "close_time", "open", "high", "low", "close", "volume"]
            record = {
                "open_time": datetime.fromtimestamp(int(row[0])/1000).isoformat(),
                "close_time": datetime.fromtimestamp(int(row[6])/1000).isoformat(),
                "base_currency": base_currency,
                "quote_currency": quote_currency,
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

# --run script to get coin rates and save to CSV file
if __name__ == "__main__":
    DATA_PATH = r"../source_data/transactions_summary.json"
    OUTPUT_PATH = r"../output/raw_rates/rates.csv" 
    with open(DATA_PATH, "r") as f:
        coins = json.load(f)

    all_prices = []

    # Lặp qua từng coin
    for coin_info in coins:
        coin = coin_info["coin"]
        min_time = coin_info["min_time"]
        max_time = coin_info["max_time"]

        logging.warning(f"Fetching price for {coin} from {min_time} to {max_time} ...")
        prices = get_coin_price_1h(base_currency=coin, quote_currency="USDT", start_date=min_time, end_date=max_time)
        all_prices.extend(prices)

    # Chuyển sang DataFrame và xuất CSV
    df = pd.DataFrame(all_prices)
    df.to_csv(OUTPUT_PATH, index=False)
    logging.warning("Done! saved to {OUTPUT_PATH}")