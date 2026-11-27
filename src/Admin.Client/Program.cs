using System.Text;

Console.OutputEncoding = Encoding.UTF8;

string apiBaseUrl = Environment.GetEnvironmentVariable("ApiClient__BaseUrl") ?? "http://localhost:5080";

Console.WriteLine("=== Mass Notification System - Admin Console Client ===");
Console.WriteLine($"API Base URL: {apiBaseUrl}");
Console.WriteLine("Khung ứng dụng Console đã khởi tạo sẵn sàng (.NET 10).");
