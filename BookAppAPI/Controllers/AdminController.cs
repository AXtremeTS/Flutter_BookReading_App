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
    [Authorize(Roles = "admin")]
    public class AdminController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public AdminController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("users")]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers()
        {
            return await _context.Users
                .Select(u => new UserDto
                {
                    UserId = u.UserId,
                    FullName = u.FullName,
                    Email = u.Email,
                    Username = u.Username,
                    Role = u.Role,
                    AvatarUrl = u.AvatarUrl,
                    IsActive = u.IsActive,
                    CreatedAt = u.CreatedAt
                })
                .ToListAsync();
        }

        [HttpGet("books")]
        public async Task<ActionResult<IEnumerable<BookDto>>> GetAllBooks()
        {
            var books = await _context.Books
                .Include(b => b.Category)
                .Include(b => b.BookTags).ThenInclude(bt => bt.Tag)
                .ToListAsync();

            return books.Select(b => new BookDto
            {
                BookId = b.BookId,
                Title = b.Title,
                Author = b.Author,
                Description = b.Description,
                ImageUrl = b.ImageUrl,
                ContentType = b.ContentType,
                FileUrl = b.FileUrl,
                CategoryId = b.CategoryId,
                CategoryName = b.Category?.CategoryName,
                TotalVotes = b.TotalVotes,
                TotalScore = b.TotalScore,
                AverageScore = b.AverageScore,
                IsCoverFromFile = b.IsCoverFromFile,
                IsHidden = b.IsHidden,
                Tags = b.BookTags.Select(bt => new TagDto
                {
                    TagId = bt.TagId,
                    TagName = bt.Tag.TagName
                }).ToList()
            }).ToList();
        }

        [HttpPost("toggle-user/{username}")]
        public async Task<IActionResult> ToggleUserStatus(string username)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
            if (user == null) return NotFound();
            
            // Calling Stored Procedure
            await _context.Database.ExecuteSqlRawAsync("EXEC sp_Admin_ToggleUserStatus @p0", user.UserId);
            return Ok();
        }

        [HttpGet("comments")]
        public async Task<ActionResult<IEnumerable<CommentDto>>> GetAllComments([FromQuery] int? bookId = null)
        {
            var query = _context.Comments.Include(c => c.User).AsQueryable();
            
            if (bookId.HasValue)
            {
                query = query.Where(c => c.BookId == bookId.Value);
            }

            var comments = await query.OrderByDescending(c => c.CreatedAt).ToListAsync();

            return comments.Select(c => new CommentDto
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
                CreatedAt = c.CreatedAt
            }).ToList();
        }

        [HttpPost("toggle-comment/{commentId}")]
        public async Task<IActionResult> ToggleCommentVisibility(int commentId)
        {
            // Calling Stored Procedure
            await _context.Database.ExecuteSqlRawAsync("EXEC sp_Admin_ToggleCommentVisibility @p0", commentId);
            return Ok();
        }

        [HttpPost("toggle-book/{bookId}")]
        public async Task<IActionResult> ToggleBookVisibility(int bookId)
        {
            var book = await _context.Books.FindAsync(bookId);
            if (book == null) return NotFound();
            
            book.IsHidden = !book.IsHidden;
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPost("books")]
        public async Task<ActionResult<BookDto>> AddBook(BookDto request)
        {
            var book = new Models.Book
            {
                Title = request.Title,
                Author = request.Author,
                Description = request.Description,
                ImageUrl = request.ImageUrl,
                CategoryId = request.CategoryId == 0 ? 1 : request.CategoryId,
                IsCoverFromFile = request.IsCoverFromFile,
                IsHidden = request.IsHidden,
                ContentType = request.ContentType ?? "volume",
            };

            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            // Handle Tags
            if (request.Tags != null && request.Tags.Any())
            {
                foreach (var tagDto in request.Tags)
                {
                    var tag = await _context.Tags.FirstOrDefaultAsync(t => t.TagName == tagDto.TagName);
                    if (tag == null)
                    {
                        tag = new Tag { TagName = tagDto.TagName };
                        _context.Tags.Add(tag);
                        await _context.SaveChangesAsync();
                    }

                    _context.BookTags.Add(new BookTag { BookId = book.BookId, TagId = tag.TagId });
                }
                await _context.SaveChangesAsync();
            }

            return Ok(new BookDto { BookId = book.BookId, Title = book.Title });
        }

        [HttpPut("books/{bookId}")]
        public async Task<IActionResult> UpdateBook(int bookId, BookDto request)
        {
            var book = await _context.Books
                .Include(b => b.BookTags)
                .FirstOrDefaultAsync(b => b.BookId == bookId);

            if (book == null) return NotFound();

            book.Title = request.Title;
            book.Author = request.Author;
            book.Description = request.Description;
            book.ImageUrl = request.ImageUrl;
            book.CategoryId = request.CategoryId == 0 ? 1 : request.CategoryId;
            book.IsCoverFromFile = request.IsCoverFromFile;
            book.IsHidden = request.IsHidden;

            // Update Tags
            if (request.Tags != null)
            {
                // Remove old tags
                _context.BookTags.RemoveRange(book.BookTags);
                
                // Add new tags
                foreach (var tagDto in request.Tags)
                {
                    var tag = await _context.Tags.FirstOrDefaultAsync(t => t.TagName == tagDto.TagName);
                    if (tag == null)
                    {
                        tag = new Tag { TagName = tagDto.TagName };
                        _context.Tags.Add(tag);
                        await _context.SaveChangesAsync();
                    }

                    _context.BookTags.Add(new BookTag { BookId = book.BookId, TagId = tag.TagId });
                }
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("books/{bookId}")]
        public async Task<IActionResult> DeleteBook(int bookId)
        {
            var book = await _context.Books.FindAsync(bookId);

            if (book == null)
            {
                return NotFound();
            }

            _context.Books.Remove(book);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
