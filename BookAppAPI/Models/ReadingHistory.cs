using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookAppAPI.Models
{
    public class ReadingHistory
    {
        [Key]
        public int HistoryId { get; set; }

        public int UserId { get; set; }
        public int BookId { get; set; }
        public int? VolumeId { get; set; }
        public int? LastReadPage { get; set; }

        public DateTime ReadAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;

        [ForeignKey("VolumeId")]
        public Volume? Volume { get; set; }
    }
}
