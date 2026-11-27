namespace Shared.Contracts.Constants;

/// <summary>
/// Các hằng số dùng chung cho RabbitMQ topology và HTTP/AMQP headers.
/// </summary>
public static class MessagingConstants
{
    public const string ExchangeName = "notifications.exchange";
    public const string SendQueueName = "notifications.send.queue";
    public const string RetryQueueName = "notifications.retry.queue";
    public const string DeadLetterQueueName = "notifications.dlq";

    public const string SendRoutingKey = "send";
    public const string RetryRoutingKey = "retry";
    public const string DeadLetterRoutingKey = "dlq";

    public const string CorrelationIdHeader = "X-Correlation-Id";
    public const string ApiKeyHeader = "X-Api-Key";

    public const string AmqpCorrelationIdHeader = "x-correlation-id";
    public const string AmqpRetryAttemptHeader = "x-retry-attempt";
    public const string AmqpCampaignIdHeader = "x-campaign-id";
    public const string AmqpDeliveryIdHeader = "x-delivery-id";
}
