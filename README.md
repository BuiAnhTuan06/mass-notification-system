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
- [03. Thiết kế CSDL & Hợp đồng bản tin](docs/03-thiet-ke-csdl-va-message.md)

## 6. Lộ trình thực hiện

Xem kế hoạch chi tiết tại [ke-hoach/cong-viec.csv](ke-hoach/cong-viec.csv) và [ke-hoach/milestones.csv](ke-hoach/milestones.csv).

## 7. Hướng dẫn cài đặt & chạy hệ thống

### Cấu trúc dự án & solution (.NET 10)

```text
MassNotificationSystem.sln
├── Directory.Build.props
├── docker-compose.yml           # Điều phối PostgreSQL, RabbitMQ và mạng notification-net
├── .env.example                 # Mẫu biến môi trường cho hạ tầng & service
├── .dockerignore
├── src/
│   ├── Shared.Contracts/        # Enum, hằng số RabbitMQ/HTTP và NotificationJobMessage
│   ├── Campaign.Api/            # ASP.NET Core Minimal API
│   ├── Notification.Worker/     # Worker Service xử lý gửi thông báo nền
│   └── Admin.Client/            # Console App quản trị chiến dịch
└── tests/
    └── MassNotification.UnitTests/  # Unit test xUnit
```

### Khởi chạy hạ tầng bằng Docker Compose

Yêu cầu cài đặt **Docker Desktop** (hoặc Docker Engine + Docker Compose).

1. Tạo file biến môi trường cục bộ từ mẫu:
   ```powershell
   Copy-Item .env.example .env
   ```
2. Khởi chạy PostgreSQL và RabbitMQ trên mạng nội bộ `notification-net`:
   ```powershell
   docker compose up -d
   docker compose ps
   ```
3. Các cổng mặc định trên máy host:
   - **PostgreSQL:** `localhost:5432`
   - **RabbitMQ AMQP:** `localhost:5672`
   - **RabbitMQ Management UI:** `http://localhost:15672`

### Build & kiểm thử cục bộ

Yêu cầu cài đặt **.NET 10 SDK**.

```powershell
dotnet restore MassNotificationSystem.sln
dotnet build MassNotificationSystem.sln --configuration Release --no-restore
dotnet test MassNotificationSystem.sln --configuration Release --no-build
```

---

**Sinh viên thực hiện:** Bui Anh Tuan (`dtc245200978@ictu.edu.vn`)
