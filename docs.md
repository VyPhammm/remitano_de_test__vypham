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