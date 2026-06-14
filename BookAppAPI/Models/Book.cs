using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookAppAPI.Models
{
    public class Book
    {
        [Key]
        public int BookId { get; set; }

        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string Author { get; set; } = string.Empty;

        public string? Description { get; set; }

        [StringLength(500)]
        public string? ImageUrl { get; set; }

        [Required]
        [StringLength(10)]
        public string ContentType { get; set; } = "file";

        [StringLength(500)]
        public string? FileUrl { get; set; }

        public int CategoryId { get; set; }

        public int TotalVotes { get; set; } = 0;
        public int TotalScore { get; set; } = 0;
        public bool IsCoverFromFile { get; set; } = false;
        public bool IsHidden { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("CategoryId")]
        public Category Category { get; set; } = null!;
        public ICollection<BookTag> BookTags { get; set; } = new List<BookTag>();
        public ICollection<Volume> Volumes { get; set; } = new List<Volume>();
        public ICollection<Rating> Ratings { get; set; } = new List<Rating>();
        public ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
        public ICollection<ReadingHistory> ReadingHistories { get; set; } = new List<ReadingHistory>();

        [NotMapped]
        public double AverageScore => TotalVotes > 0 ? (double)TotalScore / TotalVotes : 0;
    }
}
