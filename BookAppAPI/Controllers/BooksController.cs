using BookAppAPI.Data;
using BookAppAPI.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BookAppAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BooksController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public BooksController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks(
            [FromQuery] int? categoryId = null,
            [FromQuery] string? search = null)
        {
            var query = _context.Books
                .Include(b => b.Category)
                .Include(b => b.BookTags).ThenInclude(bt => bt.Tag)
                .Where(b => !b.IsHidden);

            if (categoryId.HasValue)
            {
                query = query.Where(b => b.CategoryId == categoryId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search))
            {
                query = query.Where(b => b.Title.Contains(search) || b.Author.Contains(search));
            }

            var books = await query.ToListAsync();

            return books.Select(b => MapToDto(b)).ToList();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BookDto>> GetBook(int id)
        {
            var book = await _context.Books
                .Include(b => b.Category)
                .Include(b => b.BookTags).ThenInclude(bt => bt.Tag)
                .Include(b => b.Volumes)
                .FirstOrDefaultAsync(b => b.BookId == id);

            if (book == null)
            {
                return NotFound();
            }

            return MapToDto(book, includeVolumes: true);
        }

        [HttpGet("volumes/{volumeId}")]
        public async Task<ActionResult<VolumeDto>> GetVolume(int volumeId)
        {
            var volume = await _context.Volumes.FindAsync(volumeId);

            if (volume == null)
            {
                return NotFound();
            }

            return new VolumeDto
            {
                VolumeId = volume.VolumeId,
                BookId = volume.BookId,
                VolumeNo = volume.VolumeNo,
                Title = volume.Title,
                Description = volume.Description,
                FileUrl = volume.FileUrl,
                Content = volume.Content,
                CreatedAt = volume.CreatedAt
            };
        }

        private static BookDto MapToDto(Models.Book b, bool includeVolumes = false)
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
                }).ToList(),
                Volumes = includeVolumes ? b.Volumes.Select(v => new VolumeDto
                {
                    VolumeId = v.VolumeId,
                    BookId = v.BookId,
                    VolumeNo = v.VolumeNo,
                    Title = v.Title,
                    Description = v.Description,
                    FileUrl = v.FileUrl,
                    Content = v.Content,
                    CreatedAt = v.CreatedAt
                }).OrderBy(v => v.VolumeNo).ToList() : null
            };
        }
    }
}
