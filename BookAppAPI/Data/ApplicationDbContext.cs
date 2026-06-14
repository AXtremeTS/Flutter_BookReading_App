using Microsoft.EntityFrameworkCore;
using BookAppAPI.Models;

namespace BookAppAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Tag> Tags { get; set; }
        public DbSet<Book> Books { get; set; }
        public DbSet<BookTag> BookTags { get; set; }
        public DbSet<Volume> Volumes { get; set; }
        public DbSet<Rating> Ratings { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<CommentLike> CommentLikes { get; set; }
        public DbSet<Favorite> Favorites { get; set; }
        public DbSet<ReadingHistory> ReadingHistories { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Explicitly map to the correct table name
            modelBuilder.Entity<ReadingHistory>().ToTable("ReadingHistory");

            // Configure tables with triggers to prevent EF Core OUTPUT clause issues
            modelBuilder.Entity<CommentLike>(entity =>
            {
                entity.ToTable(tb => tb.HasTrigger("trg_CommentLikes_AfterInsert"));
                entity.ToTable(tb => tb.HasTrigger("trg_CommentLikes_AfterDelete"));
            });

            modelBuilder.Entity<Rating>(entity =>
            {
                entity.ToTable(tb => tb.HasTrigger("trg_Ratings_AfterInsert"));
                entity.ToTable(tb => tb.HasTrigger("trg_Ratings_AfterUpdate"));
                entity.ToTable(tb => tb.HasTrigger("trg_Ratings_AfterDelete"));
            });

            // Composite Key for BookTag
            modelBuilder.Entity<BookTag>()
                .HasKey(bt => new { bt.BookId, bt.TagId });

            // Relationships
            modelBuilder.Entity<BookTag>()
                .HasOne(bt => bt.Book)
                .WithMany(b => b.BookTags)
                .HasForeignKey(bt => bt.BookId);

            modelBuilder.Entity<BookTag>()
                .HasOne(bt => bt.Tag)
                .WithMany(t => t.BookTags)
                .HasForeignKey(bt => bt.TagId);

            // Cascade Deletes as per SQL Script
            modelBuilder.Entity<Volume>()
                .HasOne(v => v.Book)
                .WithMany(b => b.Volumes)
                .HasForeignKey(v => v.BookId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<CommentLike>()
                .HasOne(cl => cl.Comment)
                .WithMany(c => c.CommentLikes)
                .HasForeignKey(cl => cl.CommentId)
                .OnDelete(DeleteBehavior.Cascade);

            // Handle Restrict for User-related tables to avoid multiple cascade paths
            modelBuilder.Entity<Comment>()
                .HasOne(c => c.User)
                .WithMany(u => u.Comments)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Rating>()
                .HasOne(r => r.User)
                .WithMany(u => u.Ratings)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Favorite>()
                .HasOne(f => f.User)
                .WithMany(u => u.Favorites)
                .HasForeignKey(f => f.UserId)
                .OnDelete(DeleteBehavior.Restrict);
                
            modelBuilder.Entity<ReadingHistory>()
                .HasOne(rh => rh.User)
                .WithMany(u => u.ReadingHistories)
                .HasForeignKey(rh => rh.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Comment>()
                .HasOne(c => c.Book)
                .WithMany(b => b.Comments)
                .HasForeignKey(c => c.BookId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Rating>()
                .HasOne(r => r.Book)
                .WithMany(b => b.Ratings)
                .HasForeignKey(r => r.BookId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Favorite>()
                .HasOne(f => f.Book)
                .WithMany(b => b.Favorites)
                .HasForeignKey(f => f.BookId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<ReadingHistory>()
                .HasOne(rh => rh.Book)
                .WithMany(b => b.ReadingHistories)
                .HasForeignKey(rh => rh.BookId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
