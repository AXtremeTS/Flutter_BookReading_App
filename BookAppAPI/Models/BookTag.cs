using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookAppAPI.Models
{
    public class BookTag
    {
        public int BookId { get; set; }
        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;

        public int TagId { get; set; }
        [ForeignKey("TagId")]
        public Tag Tag { get; set; } = null!;
    }
}
