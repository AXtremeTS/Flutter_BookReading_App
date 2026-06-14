namespace BookAppAPI.DTOs
{
    public class VolumeDto
    {
        public int VolumeId { get; set; }
        public int BookId { get; set; }
        public int VolumeNo { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? FileUrl { get; set; }
        public string? Content { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
