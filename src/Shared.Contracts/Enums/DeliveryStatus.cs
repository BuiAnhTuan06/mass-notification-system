using System.Text.Json.Serialization;

namespace Shared.Contracts.Enums;

/// <summary>
/// Trạng thái xử lý của từng job gửi thông báo tới một người nhận.
/// </summary>
[JsonConverter(typeof(JsonStringEnumConverter))]
public enum DeliveryStatus
{
    Pending = 0,
    Sent = 1,
    Failed = 2
}
