# remitano_de_test__vypham

Cấu trúc thư mục:
- .devcontainer: Cài môi trường local để thống nhất mọi người chung team dùng chung 1 môi trường test các dbt transform
- docker: môi trường DEV gần giống production, cho các thành viên chạy test toàn infra như airflow, dbt, ...
- orchestration: CHẠY AIRFLOW
- output
    + raw_rates: dữ liệu coin 1 h, dùng cho bronze data
- scripts
- source_data
    + giả sử là source data, dùng cho bronze data
- transform

- .github-ci.yml
- README.md



--------------------------------
Architecture model: cách modeling data

***BRONZE***
transactions.csv: Ghi lại lịch sử giao dịch của người dùng.
    - tx_id: Mã giao dịch (unique)
    - user_id: Mã người dùng
    - source_currency: Loại tiền tệ nguồn (ví dụ: BTC, ETH)
    - destination_currency: Loại tiền tệ đích (ví dụ: USDT, VND)
    - source_amount: Số lượng tiền nguồn
    - destination_amount: Số lượng tiền đích
    - created_at: Thời gian giao dịch (UTC)
    - status: Trạng thái 

users.csv: Thông tin người dùng.
    - user_id: Mã người dùng (unique)
    - kyc_level: Cấp độ xác minh danh tính (ví dụ: L0, L1, L2)
    - created_at: Thời gian tạo tài khoản
    - updated_at: Thời gian cập nhật thông tin lần cuối

rates: Tỷ giá tiền tệ so với USDT theo giờ
    - open_time : Thời điểm open giá theo nến 1H
    - close_time: thời điểm close giá theo nến 1H
    - base_currency: tiền tệ cần lấy rate
    - quote_currency: tiền tệ đối chiếu,  mặc định là USDT
    - symbol: ký hiệu cặp tiền lấy tỷ giá, vd: ADAUSDT
    - open: giá mở cửa nến 1H
    - high: giá cao nhất nến 1H
    - low: giá thấp nhất nến 1H
    - close: giá đóng cửa nến 1H

***SILVER***


# Data Modeling Documentation

## 1. Folder Structure & Model Description

Dự án sử dụng cấu trúc dbt project để chuyển đổi dữ liệu, tổ chức theo các lớp:

- **staging/**: Tải dữ liệu thô từ nguồn, làm sạch cơ bản.
  - `bronze_stg_transactions.sql`, `bronze_stg_users.sql`, `bronze_stg_rates.sql`
- **int/** (Intermediate/Silver): Áp dụng logic nghiệp vụ, join, chuẩn bị dữ liệu cho phân tích.
  - `silver_int_transactions.sql`, `silver_int_user_kyc_history.sql`
- **marts/** (Gold): Bảng tổng hợp cuối cùng phục vụ báo cáo.
  - `gold_marts_transactions_completed_kyc.sql`, `gold_marts_transactions_volume.sql`
- **example/**: Các mô hình và schema mẫu.

## 2. Sơ Đồ Mô Hình Dữ Liệu (Text-Based)

```
[Raw Sources]
   |
   v
[staging/bronze_stg_transactions]   [staging/bronze_stg_users]   [staging/bronze_stg_rates]
   |                |                     |
   v                v                     v
[int/silver_int_transactions]   [int/silver_int_user_kyc_history]
   |                |
   v                v
[marts/gold_marts_transactions_completed_kyc]   [marts/gold_marts_transactions_volume]
```

- Mũi tên thể hiện luồng dữ liệu: raw → staging → intermediate → marts.

## 3. Giải Thích Chọn Mô Hình

Bạn chọn mô hình **layered data modeling (bronze-silver-gold)** vì:

- **Dễ quản lý**: Tách biệt các bước làm sạch, xử lý, và tổng hợp dữ liệu.
- **Tái sử dụng**: Các bảng intermediate có thể dùng cho nhiều báo cáo khác nhau.
- **Kiểm soát chất lượng**: Dễ kiểm tra và debug từng bước.
- **Chuẩn hóa**: Phù hợp với best practices của dbt và các dự án data warehouse hiện đại.

**Tóm lại:** Mô hình này giúp phát triển, bảo trì và mở rộng hệ thống dữ liệu hiệu quả, minh bạch.