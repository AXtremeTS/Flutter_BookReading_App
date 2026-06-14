using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookAppAPI.Models
{
    public class Rating
    {
        [Key]
        public int RatingId { get; set; }

        public int UserId { get; set; }
        public int BookId { get; set; }

        [Range(1, 5)]
        public byte Score { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;
    }
}
