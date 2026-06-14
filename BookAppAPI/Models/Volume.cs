using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookAppAPI.Models
{
    public class Volume
    {
        [Key]
        public int VolumeId { get; set; }

        public int BookId { get; set; }

        [Required]
        public int VolumeNo { get; set; }

        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; }

        [StringLength(500)]
        public string? FileUrl { get; set; }

        public string? Content { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;

        public ICollection<Comment> Comments { get; set; } = new List<Comment>();
    }
}
