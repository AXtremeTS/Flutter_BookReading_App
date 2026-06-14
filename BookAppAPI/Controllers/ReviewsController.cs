using System.Security.Claims;
using BookAppAPI.Data;
using BookAppAPI.DTOs;
using BookAppAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BookAppAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ReviewsController(ApplicationDbContext context)
        {
            _context = context;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
            if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
            {
                return userId;
            }
            return 0; // Return 0 if not logged in or claim is invalid
        }


        [HttpGet("book/{bookId}")]
        public async Task<ActionResult<IEnumerable<CommentDto>>> GetBookComments(int bookId)
        {
            var userId = GetUserId();

            var comments = await _context.Comments
                .Include(c => c.User)
                .Where(c => c.BookId == bookId && c.ParentCommentId == null && !c.IsHidden)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            var likedCommentIds = new HashSet<int>();
            if (userId > 0)
            {
                var commentIdsForBook = comments.Select(c => c.CommentId).ToList();
                likedCommentIds = (await _context.CommentLikes
                    .Where(cl => cl.UserId == userId && commentIdsForBook.Contains(cl.CommentId))
                    .Select(cl => cl.CommentId)
                    .ToListAsync()).ToHashSet();
            }

            return comments.Select(c => MapToDto(c, likedCommentIds)).ToList();
        }

        [Authorize]
        [HttpPost]
        public async Task<ActionResult<CommentDto>> PostComment(CreateCommentDto request)
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var comment = new Comment
            {
                BookId = request.BookId,
                VolumeId = request.VolumeId,
                UserId = userId,
                ParentCommentId = request.ParentCommentId,
                Content = request.Content,
                Score = (byte?)request.Score,
                CreatedAt = DateTime.UtcNow,
                LikeCount = 0
            };

            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();
            
            await _context.Entry(comment).Reference(c => c.User).LoadAsync();

            return Ok(MapToDto(comment, new HashSet<int>()));
        }

        [Authorize]
        [HttpPost("{commentId}/like")]
        public async Task<IActionResult> LikeComment(int commentId)
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var existingLike = await _context.CommentLikes
                .FirstOrDefaultAsync(cl => cl.CommentId == commentId && cl.UserId == userId);

            if (existingLike != null)
            {
                // Unlike: The database trigger 'trg_CommentLikes_AfterDelete' will handle the count.
                _context.CommentLikes.Remove(existingLike);
            }
            else
            {
                // Like: The database trigger 'trg_CommentLikes_AfterInsert' will handle the count.
                _context.CommentLikes.Add(new CommentLike
                {
                    CommentId = commentId,
                    UserId = userId
                });
            }

            await _context.SaveChangesAsync();

            // Re-fetch the comment to get the updated count from the trigger.
            var updatedComment = await _context.Comments.AsNoTracking().FirstOrDefaultAsync(c => c.CommentId == commentId);
            
            return Ok(new { newLikeCount = updatedComment?.LikeCount ?? 0 });
        }

        private static CommentDto MapToDto(Comment c, HashSet<int> likedCommentIds)
        {
            return new CommentDto
            {
                CommentId = c.CommentId,
                BookId = c.BookId,
                VolumeId = c.VolumeId,
                UserId = c.UserId,
                Username = c.User.Username,
                AvatarUrl = c.User.AvatarUrl,
                ParentCommentId = c.ParentCommentId,
                Content = c.Content,
                Score = c.Score,
                LikeCount = c.LikeCount,
                IsHidden = c.IsHidden,
                CreatedAt = c.CreatedAt,
                IsLiked = likedCommentIds.Contains(c.CommentId)
            };
        }
    }
}
