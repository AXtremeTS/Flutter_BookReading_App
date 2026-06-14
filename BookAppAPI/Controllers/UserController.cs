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
    [Authorize]
    public class UserController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public UserController(ApplicationDbContext context)
        {
            _context = context;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
            if (userIdClaim == null)
            {
                Console.WriteLine("DEBUG: No User ID claim found in token.");
                throw new UnauthorizedAccessException();
            }

            if (!int.TryParse(userIdClaim.Value, out int userId))
            {
                Console.WriteLine($"DEBUG: Could not parse User ID claim value: {userIdClaim.Value}");
                throw new UnauthorizedAccessException();
            }

            Console.WriteLine($"DEBUG: Request from User ID: {userId}");
            return userId;
        }

        [HttpGet("favorites")]
        public async Task<ActionResult<IEnumerable<BookDto>>> GetFavorites()
        {
            try
            {
                var userId = GetUserId();
                var favorites = await _context.Favorites
                    .Include(f => f.Book).ThenInclude(b => b.Category)
                    .Include(f => f.Book).ThenInclude(b => b.BookTags).ThenInclude(bt => bt.Tag)
                    .Where(f => f.UserId == userId)
                    .Select(f => f.Book)
                    .ToListAsync();

                Console.WriteLine($"DEBUG: Found {favorites.Count} favorites for user {userId}");
                return favorites.Select(b => MapToBookDto(b)).ToList();
            }
            catch (UnauthorizedAccessException) { return Unauthorized(); }
        }

        [HttpPost("favorites/{bookId}")]
        public async Task<IActionResult> ToggleFavorite(int bookId)
        {
            try
            {
                var userId = GetUserId();
                var favorite = await _context.Favorites
                    .FirstOrDefaultAsync(f => f.UserId == userId && f.BookId == bookId);

                if (favorite != null)
                {
                    _context.Favorites.Remove(favorite);
                    Console.WriteLine($"DEBUG: Removed book {bookId} from favorites for user {userId}");
                }
                else
                {
                    _context.Favorites.Add(new Favorite { UserId = userId, BookId = bookId });
                    Console.WriteLine($"DEBUG: Added book {bookId} to favorites for user {userId}");
                }

                await _context.SaveChangesAsync();
                return Ok();
            }
            catch (UnauthorizedAccessException) { return Unauthorized(); }
        }

        [HttpGet("history")]
        public async Task<ActionResult<IEnumerable<HistoryDto>>> GetHistory()
        {
            try
            {
                var userId = GetUserId();
                var history = await _context.ReadingHistories
                    .Include(h => h.Book)
                    .Include(h => h.Volume)
                    .Where(h => h.UserId == userId)
                    .OrderByDescending(h => h.ReadAt)
                    .ToListAsync();

                Console.WriteLine($"DEBUG: Found {history.Count} history items for user {userId}");
                return history.Select(h => new HistoryDto
                {
                    HistoryId = h.HistoryId,
                    BookId = h.BookId,
                    BookTitle = h.Book.Title,
                    BookImageUrl = h.Book.ImageUrl,
                    VolumeId = h.VolumeId,
                    VolumeTitle = h.Volume?.Title,
                    LastReadPage = h.LastReadPage,
                    ReadAt = h.ReadAt
                }).ToList();
            }
            catch (UnauthorizedAccessException) { return Unauthorized(); }
        }

        [HttpPost("history")]
        public async Task<IActionResult> AddOrUpdateHistory(CreateHistoryDto request)
        {
            try
            {
                var userId = GetUserId();
                Console.WriteLine($"DEBUG: Saving history for Book {request.BookId}, Volume {request.VolumeId} for user {userId}");

                var history = await _context.ReadingHistories
                    .FirstOrDefaultAsync(h => h.UserId == userId && h.BookId == request.BookId);

                if (history != null)
                {
                    history.VolumeId = request.VolumeId;
                    history.LastReadPage = request.LastReadPage;
                    history.ReadAt = DateTime.UtcNow;
                    Console.WriteLine($"DEBUG: Updated existing history entry for user {userId}");
                }
                else
                {
                    _context.ReadingHistories.Add(new ReadingHistory
                    {
                        UserId = userId,
                        BookId = request.BookId,
                        VolumeId = request.VolumeId,
                        LastReadPage = request.LastReadPage,
                        ReadAt = DateTime.UtcNow
                    });
                    Console.WriteLine($"DEBUG: Created new history entry for user {userId}");
                }

                await _context.SaveChangesAsync();
                return Ok();
            }
            catch (UnauthorizedAccessException) { return Unauthorized(); }
            catch (Exception ex)
            {
                Console.WriteLine($"DEBUG: ERROR saving history: {ex.Message}");
                return BadRequest(ex.Message);
            }
        }

        private static BookDto MapToBookDto(Book b)
        {
            return new BookDto
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
            };
        }
    }
}
