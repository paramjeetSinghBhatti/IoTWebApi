using Microsoft.EntityFrameworkCore;

namespace IoTWebApi
{
    public class WeatherDbContext : DbContext
    {
        public WeatherDbContext(DbContextOptions<WeatherDbContext> contextOptions) : base(contextOptions)
        {

        }
        public DbSet<Weather> Weathers { get; set; }

        public void Save(Weather weather)
        {
            Weathers.Add(weather);
        }
    }
}
