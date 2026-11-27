using System.Text.Json.Serialization;

namespace Shared.Contracts.Enums;

/// <summary>
/// Trạng thái vòng đời của chiến dịch thông báo.
/// </summary>
[JsonConverter(typeof(JsonStringEnumConverter))]
public enum CampaignStatus
{
    Draft = 0,
    Running = 1,
    Completed = 2
}
