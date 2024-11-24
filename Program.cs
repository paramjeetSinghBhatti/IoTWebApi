using IoTWebApi;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<WeatherDbContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
});

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();
//app.UseRouting();
app.MapPost("/iot/telemetry", async (Weather weather, WeatherDbContext dbContext) =>
{
    dbContext.Save(weather);
    await dbContext.SaveChangesAsync();
    return Results.Created();

});

app.MapGet("/iot/telemetry", () =>
{
    return Results.Ok("I am working api.");

});

app.MapControllers();

app.Run();
