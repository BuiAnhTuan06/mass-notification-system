namespace Notification.Worker;

/// <summary>
/// Tiến trình nền xử lý job gửi thông báo bất đồng bộ (khung khởi tạo).
/// </summary>
public sealed class Worker(ILogger<Worker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        string workerInstance = Environment.MachineName;
        logger.LogInformation("Notification.Worker ({WorkerInstance}) đã khởi động.", workerInstance);

        try
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
            }
        }
        catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
        {
            // Bỏ qua ngoại lệ hủy khi host dừng bình thường.
        }
        finally
        {
            logger.LogInformation("Notification.Worker ({WorkerInstance}) đã dừng.", workerInstance);
        }
    }
}
