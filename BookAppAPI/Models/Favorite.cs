using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookAppAPI.Models
{
    public class Favorite
    {
        [Key]
        public int FavoriteId { get; set; }

        public int UserId { get; set; }
        public int BookId { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;
    }
}
