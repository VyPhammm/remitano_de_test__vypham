config: lưu các dependent của các model
data_pipeline: lưu các DAG chạy load và transform data
    - load: lưu các DAG chạy load data từ data_lake vào DWH 
    - transform: transform data bằng dbt
utils: các DAG chạy với mục đích chung như: dọn dẹp log airflow, code noti khi dùng airflow

