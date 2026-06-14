namespace BookAppAPI.DTOs
{
    public class HistoryDto
    {
        public int HistoryId { get; set; }
        public int BookId { get; set; }
        public string BookTitle { get; set; } = string.Empty;
        public string? BookImageUrl { get; set; }
        public int? VolumeId { get; set; }
        public string? VolumeTitle { get; set; }
        public int? LastReadPage { get; set; }
        public DateTime ReadAt { get; set; }
    }

    public class CreateHistoryDto
    {
        public int BookId { get; set; }
        public int? VolumeId { get; set; }
        public int? LastReadPage { get; set; }
    }
}
