var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapGet("/", () => Results.Ok(new
{
    service = "Campaign.Api",
    status = "Running",
    timestampUtc = DateTimeOffset.UtcNow
}));

app.MapHealthChecks("/health/live");

app.Run();

public partial class Program
{
}
