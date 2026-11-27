using Shared.Contracts.Enums;

namespace Shared.Contracts.Messages;

/// <summary>
/// Hợp đồng bản tin job gửi thông báo đẩy qua RabbitMQ.
/// </summary>
public sealed record NotificationJobMessage(
    Guid MessageId,
    Guid DeliveryId,
    Guid CampaignId,
    Guid RecipientId,
    NotificationChannel Channel,
    string RecipientAddress,
    string? RecipientName,
    string? Subject,
    string Body,
    int RetryAttempt,
    int ManualRetryGeneration,
    string CorrelationId,
    DateTimeOffset EnqueuedAtUtc
);
