namespace BookAppAPI.DTOs
{
    public class BookDto
    {
        public int BookId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Author { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public string ContentType { get; set; } = "file";
        public string? FileUrl { get; set; }
        public int CategoryId { get; set; }
        public string? CategoryName { get; set; }
        public int TotalVotes { get; set; }
        public int TotalScore { get; set; }
        public double AverageScore { get; set; }
        public bool IsCoverFromFile { get; set; }
        public bool IsHidden { get; set; }
        public List<TagDto> Tags { get; set; } = new();
        public List<VolumeDto>? Volumes { get; set; }
    }
}
