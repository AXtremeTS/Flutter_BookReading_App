using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookAppAPI.Models
{
    public class Comment
    {
        [Key]
        public int CommentId { get; set; }

        public int BookId { get; set; }
        public int? VolumeId { get; set; }
        public int UserId { get; set; }
        public int? ParentCommentId { get; set; }

        [Required]
        public string Content { get; set; } = string.Empty;

        public byte? Score { get; set; }
        public int LikeCount { get; set; } = 0;
        public bool IsHidden { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;

        [ForeignKey("VolumeId")]
        public Volume? Volume { get; set; }

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [ForeignKey("ParentCommentId")]
        public Comment? ParentComment { get; set; }

        public ICollection<Comment> Replies { get; set; } = new List<Comment>();
        public ICollection<CommentLike> CommentLikes { get; set; } = new List<CommentLike>();
    }
}
