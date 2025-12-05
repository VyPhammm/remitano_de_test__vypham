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
