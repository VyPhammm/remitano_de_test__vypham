## ARCHITECTURE

## Data Modeling Documentation

## 1. Folder Structure & Model Description

Dự án sử dụng cấu trúc dbt project để chuyển đổi dữ liệu. 
Modeling data theo Medallion architecture: Bronze - Silver - Gold
- **raw_bronze/**: Tải dữ liệu thô từ nguồn, làm sạch cơ bản.
  + `các raw data lưu trên DWH: transactions, users, rates`
- **staging/**: Tải dữ liệu thô từ raw_bronze, làm sạch cơ bản, chuẩn hóa kiểu dữ liệu.
  + `bronze_stg_transactions.sql`, `bronze_stg_users.sql`, `bronze_stg_rates.sql`
- **int/** (Silver): Áp dụng logic nghiệp vụ, join, chuẩn bị dữ liệu cho phân tích.
  + `silver_int_transactions.sql` : Enrich dữ liệu transactions
  + `silver_int_user_kyc_history.sql` : Lưu trữ dữ liệu KYC của người dùng (lớp raw SCD type 1 không lưu lịch sử KYC users)
- **marts/** (Gold): Bảng tổng hợp cuối cùng phục vụ báo cáo, BI.
  + `gold_marts_transactions_completed_kyc.sql`: Thông tin các giao dịch đã hoàn thành, theo dõi KYC users tại thời điểm giao dịch.
  + `gold_marts_transactions_volume.sql`: Thông tin tổng khối lượng giao dịch (USD) theo ngày, tháng, quý.

## 2. Sơ Đồ Mô Hình Dữ Liệu (Text-Based)

```
[Raw Sources]
   |
   v
[staging/bronze_stg_transactions] [staging/bronze_stg_rates] [staging/bronze_stg_users]   
   |                                    |                     |
   v                                    v                     v
[int/silver_int_transactions             ]               [int/silver_int_user_kyc_history]
   |                |
   v                v
[marts/gold_marts_transactions_completed_kyc]   [marts/gold_marts_transactions_volume]

```

- Mũi tên thể hiện luồng dữ liệu: Source (Raw_Bronze) → staging (Bronze) → intermediate (Silver) → marts (Gold)

## 3. Giải Thích chọn mô hình Medallion architecture

Chọn mô hình Medallion architecture và chia thành các layers như trên vì:
- **Dễ quản lý và tái sử dụng**: Tận dụng tính năng modular data modeling của dbt để dễ quản tý, tái sử dụng các data model.
- **Dễ debuging và lineage data rõ**: chia thành các tầng dễ debug và phát hiện lỗi
- **Tách biệt theo data quality**: chia trách nhiệm cải thiện data quality rõ theo từng lớp, phù hợp với nhiều mục đích phân tích.
- **Hỗ trợ phân tích BI + ML trên cùng 1 platform**: platform có thể cùng cung cấp layer Bronze+ Silver cho mục đích ML, AI; và Gold cho các tác vụ BI.
- **Dễ replay data khi có thay đổi**: raw data lưu hết tại Bronze nên khi cần chạy lại data model rất dễ.
- **Phù hợp với kiến trúc LakeHouse**: Phù hợp với các kiến trúc modern data platform, Lakehouse có phân chia Storage, Compute engine tách rời.

## 3. Giải Thích model data lưu lịch sử KYC của user:
- **Bối cảnh**: data từ bảng user, không có tracking lịch sử KYC, data mới overwrite vào cái cũ và thay đổi updated_at.
- **Giải quyết**:
    - model data theo kiểu SCD type 2 để tracking dữ liệu KYC.
    - Sử dụng materialized kiểu incremental theo stategy merge để xử lý dữ liệu, thêm vào post-hook custom merge cho phù hợp với logic:
        + Nhận định 1 dữ liệu mới là khi dữ liệu có thay đổi ở 1 trong 3 cột: 'user_id', 'kyc_level', 'updated_at'
        + Nếu user_id chưa tồn tại --> thêm vào dòng dữ liệu mới đó
        + Nếu user_id đã tôn tại, ngày kyc hết hiệu lực (effective_to - với data mới, giá trị là NULL) là NULL, KYC_level thay đổi
        --> thì cập nhật ngày effective_to ở giá trị cũ từ NULL thành updated_at ở data mới 
            và thêm vào dòng data mới này vào bảng.
    - model sẽ có: dữ liệu KYC mới, dữ liệu KYC cũ được update cột effective_to cho phù hợp.

## 4. Kiến trúc & Lưu trữ
**4.1 Lựa chọn DWH**: 
- Nếu triển khai thực tế cho dự án này, tôi sẽ chọn DWH: Snowflake, Databricks
- Lý do:
    + Compute và Storage tách riêng, phù hợp với chia theo data quality như kiến trúc này.
    + Dễ quản lý, tối ưu chi phí.
    + 1 data platform linh hoạc và thích hợp cho cả mục địch ML/AI và BI.
    + Hỗ trợ mạnh ingest data từ nhièu nguồn vào raw bronze - bronze.
    + Dễ scale.
**4.2 Chiến lược Materialization**: 
- Trong dbt, tôi chọn chiến lược chọn Materialization (view, table, incremental, ephemeral) cho các model theo các nguyên tắc:
    + Bronze - staging: Dùng **VIEW** vì ở đây chỉ transform data nhẹ, rename, cast lại type cột, nên dùng view để tối ưu cost lưu trũ trên DB.
    + Silver - int: Vì xử lý transform data nặng, apply nhiều business logic và phải xử lý khối lượng lớn data nên ưu tiên dùng **INCREMENTAL** với strategy phù hợp để tối ưu cost transform dữ liệu - chỉ xử lý 1 phần dữ liệu. Nếu model nào xử lý lượng nhỏ data thì dùng **TABLE** để tăng hiệu suất query ở các model upstream.
    + Gold - mart: Hầu hết dùng dạng **Table** vì phần lớn dùng vào mục đich BI, visulization ở BI tool nên dùng **TABLE** để query nhanh. Nếu các bảng quá lớn thì dùng **INCREMENTAL** với strategy phù hợp để giảm thiểu cost.
    + **Ephemeral**: Nếu logic biến đổi ở các layer int, marts quá phức tạp và có reuse lại nhiều lại thì tách logic đó ra và lưu vào thành Ephemeral model.

**4.3 Orchestration (Lên lịch)**:
Mô tả ngắn gọn cách bạn sẽ lên lịch (orchestrate) để pipeline này chạy hàng ngày (bao gồm cả Bài 1 và Bài 2). Nêu công cụ bạn chọn (ví dụ: Airflow, Dagster, dbt Cloud, Cron...) và mô tả các dependencies giữa các task.

- Với dự án này tôi sẽ thiết lập lên lịch các pipeline như sau:
    + Pipeline ingest data rates: Lập lịch chạy mỗi 1H vì đang lấy giá theo phiên 1H.
    + dbt-data-pipeline: Vì là dữ liệu finance quan trọng với hoạt động của công ty nên cân nhắc lên lịch:
        ++ các model liên quan transacions và rate cho chạy 1H vì là dữ liệu quan trọng và có các metrics để monitor và ảnh hưởng hoạt động kinh doanh
        ++ các model liên quan KYC có thể để lịch quan trọng thấp hơn (như 2H, 4H, 6H, 12H, 1D)
        ++ model ở tầng gold, phục vụ mục đích cho báo cáo theo ngày / tháng / năm , có thể lên lịch theo (12H, 1D) để giảm chi phí
        ++ model ở tàng gold, phục vụ mục đích monitor, báo cáo thường xuyên thì để schedule thấp hơn (1H, 2H)
- Với dự án này tôi sẽ dùng Airflow (giảm chi phí vận hành), scheduled các DAG là 1H, các dependencies tôi thiết lập giữa các task:
    + get_coin_rate: pipeline lấy currency rate  - dependencies: get_transactions_summary --> get_coin_rate
    + dbt project: pipeline modeling data - 
        dependencies:
        (wait cho pipeline này lấy data xong, nếu sau 1 thời gian chưa xong thì chạy luôn - get_coin_rate) 
        --> [staging] --> [int] --> [marts]


