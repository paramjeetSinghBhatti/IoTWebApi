using System.ComponentModel.DataAnnotations;

public class Weather
{
    [Key]
    public int Id { get; set; }
    public string Tempearture { get; set; }
    public string Humidity { get; set; }
}