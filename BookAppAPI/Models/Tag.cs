using System.ComponentModel.DataAnnotations;

namespace BookAppAPI.Models
{
    public class Tag
    {
        [Key]
        public int TagId { get; set; }

        [Required]
        [StringLength(50)]
        public string TagName { get; set; } = string.Empty;

        public ICollection<BookTag> BookTags { get; set; } = new List<BookTag>();
    }
}
