using System.Text.Json;
using Shared.Contracts.Constants;
using Shared.Contracts.Enums;
using Shared.Contracts.Messages;

namespace MassNotification.UnitTests;

public class SharedContractsTests
{
    private static readonly JsonSerializerOptions WebJsonOptions = new(JsonSerializerDefaults.Web);

    [Fact]
    public void NotificationJobMessage_ShouldRoundTripWithStringEnumsAndCamelCase()
    {
        var original = new NotificationJobMessage(
            MessageId: Guid.CreateVersion7(),
            DeliveryId: Guid.CreateVersion7(),
            CampaignId: Guid.CreateVersion7(),
            RecipientId: Guid.CreateVersion7(),
            Channel: NotificationChannel.Email,
            RecipientAddress: "sinhvien01@ictu.edu.vn",
            RecipientName: "Nguyen Van A",
            Subject: "Thong bao lich thi",
            Body: "Kiem tra lich thi truoc ngay 30/11.",
            RetryAttempt: 0,
            ManualRetryGeneration: 0,
            CorrelationId: "corr-test-001",
            EnqueuedAtUtc: new DateTimeOffset(2026, 11, 27, 16, 0, 0, TimeSpan.Zero)
        );

        string json = JsonSerializer.Serialize(original, WebJsonOptions);
        NotificationJobMessage? deserialized = JsonSerializer.Deserialize<NotificationJobMessage>(json, WebJsonOptions);

        Assert.Contains("\"channel\":\"Email\"", json);
        Assert.Contains("\"deliveryId\":", json);
        Assert.Equal(original, deserialized);
    }

    [Fact]
    public void MessagingConstants_ShouldMatchArchitectureSpecification()
    {
        Assert.Equal("notifications.exchange", MessagingConstants.ExchangeName);
        Assert.Equal("notifications.send.queue", MessagingConstants.SendQueueName);
        Assert.Equal("notifications.retry.queue", MessagingConstants.RetryQueueName);
        Assert.Equal("notifications.dlq", MessagingConstants.DeadLetterQueueName);

        Assert.Equal("send", MessagingConstants.SendRoutingKey);
        Assert.Equal("retry", MessagingConstants.RetryRoutingKey);
        Assert.Equal("dlq", MessagingConstants.DeadLetterRoutingKey);

        Assert.Equal("X-Correlation-Id", MessagingConstants.CorrelationIdHeader);
        Assert.Equal("X-Api-Key", MessagingConstants.ApiKeyHeader);
    }
}
