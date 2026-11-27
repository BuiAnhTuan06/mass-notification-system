using System.Text.Json.Serialization;

namespace Shared.Contracts.Enums;

/// <summary>
/// Kênh gửi thông báo của chiến dịch.
/// </summary>
[JsonConverter(typeof(JsonStringEnumConverter))]
public enum NotificationChannel
{
    Email = 0,
    Sms = 1
}
