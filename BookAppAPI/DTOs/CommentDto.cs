namespace BookAppAPI.DTOs
{
    public class CommentDto
    {
        public int CommentId { get; set; }
        public int BookId { get; set; }
        public int? VolumeId { get; set; }
        public int UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        public int? ParentCommentId { get; set; }
        public string Content { get; set; } = string.Empty;
        public int? Score { get; set; }
        public int LikeCount { get; set; }
        public bool IsHidden { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsLiked { get; set; }
    }

    public class CreateCommentDto
    {
        public int BookId { get; set; }
        public int? VolumeId { get; set; }
        public int? ParentCommentId { get; set; }
        public required string Content { get; set; }
        public int? Score { get; set; }
    }
}
