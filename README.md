# Đề tài 11 – Hệ thống gửi thông báo hàng loạt (Mass Notification System)

Bài tập lớn học phần **Phát triển ứng dụng phân tán**.

## 1. Giới thiệu

Xây dựng hệ thống cho phép tạo và quản lý các chiến dịch gửi thông báo đến nhiều người nhận. API chỉ tiếp nhận yêu cầu và tạo chiến dịch; các thông báo cụ thể được chia thành job, đẩy qua **RabbitMQ** và xử lý bất đồng bộ bởi nhiều **Notification Worker** độc lập.

## 2. Kiến trúc tổng quan

```text
Admin Client (Console) -> Campaign API (.NET 10 Minimal API) -> RabbitMQ -> Notification Workers (1..N)
                                |                                                |
                                +------------------> PostgreSQL <----------------+
```

## 3. Công nghệ sử dụng

- **Ngôn ngữ & nền tảng:** C#, .NET 10
- **API:** ASP.NET Core Minimal API
- **Client:** Console App
- **Message Broker:** RabbitMQ
- **Cơ sở dữ liệu:** PostgreSQL + Entity Framework Core
- **Đóng gói & triển khai:** Docker, Docker Compose

## 4. Các chức năng chính

1. Tạo chiến dịch thông báo.
2. Chọn hoặc nhập danh sách người nhận (nhập tay / file CSV).
3. Sinh các job gửi thông báo và đưa vào RabbitMQ.
4. Nhiều Worker nhận và xử lý job độc lập.
5. Ghi nhận kết quả thành công (`Sent`) hoặc thất bại (`Failed`) của từng thông báo.
6. Theo dõi số lượng `Pending`, `Sent`, `Failed` của chiến dịch.
7. Tra cứu chi tiết kết quả gửi.
8. Chạy lại các job thất bại theo cơ chế phù hợp.

## 5. Tài liệu dự án

- [01. Phân tích yêu cầu & Đặc tả Use Case](docs/01-phan-tich-yeu-cau.md)
- [02. Thiết kế kiến trúc hệ thống](docs/02-kien-truc.md)

## 6. Lộ trình thực hiện

Xem kế hoạch chi tiết tại [ke-hoach/cong-viec.csv](ke-hoach/cong-viec.csv) và [ke-hoach/milestones.csv](ke-hoach/milestones.csv).

## 7. Hướng dẫn cài đặt & chạy hệ thống

*(Sẽ được cập nhật chi tiết khi hoàn thiện cấu trúc solution và `docker-compose.yml`)*

---

**Sinh viên thực hiện:** Bui Anh Tuan (`dtc245200978@ictu.edu.vn`)
