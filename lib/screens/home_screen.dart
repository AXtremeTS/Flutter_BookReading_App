import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/book_service.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/book_list_item.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';

enum ViewMode { grid, list }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Book> _displayedBooks = [];
  final List<String> _selectedTags = [];
  bool _isLoading = true;
  ViewMode _viewMode = ViewMode.grid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _bookService.loadSavedData();
    if (mounted) {
      setState(() {
        _displayedBooks = _bookService.allBooks;
        _isLoading = false;
      });
    }
  }

  void _searchBooks(String query) {
    setState(() {
      if (_selectedTags.isEmpty) {
        _displayedBooks = _bookService.searchBooks(query);
      } else {
        final filteredByTags = _bookService.filterByTags(_selectedTags);
        _displayedBooks = filteredByTags.where((book) {
          return book.title.toLowerCase().contains(query.toLowerCase()) ||
              book.author.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterByTags() {
    setState(() {
      if (_selectedTags.isEmpty) {
        _displayedBooks = _bookService.searchBooks(_searchController.text);
      } else {
        _displayedBooks = _bookService.filterByTags(_selectedTags);
        if (_searchController.text.isNotEmpty) {
          _searchBooks(_searchController.text);
        }
      }
    });
  }

  void _showTagFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : AppColors.canvas,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filter by Tags',
                              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() => _selectedTags.clear());
                                setState(() => _filterByTags());
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(24),
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _bookService.getAllTags().map((tag) {
                                final isSelected = _selectedTags.contains(tag);
                                return FilterChip(
                                  label: Text(tag),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      if (selected) {
                                        _selectedTags.add(tag);
                                      } else {
                                        _selectedTags.remove(tag);
                                      }
                                    });
                                    setState(() => _filterByTags());
                                  },
                                  backgroundColor: isDark ? const Color(0xFF2C2C2C) : AppColors.surfaceSoft,
                                  selectedColor: isDark ? AppColors.blockMint : AppColors.blockLime,
                                  checkmarkColor: isDark ? Colors.white : AppColors.ink,
                                  labelStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    side: BorderSide(
                                      color: isSelected 
                                          ? (isDark ? Colors.white : AppColors.primary)
                                          : (isDark ? const Color(0xFF3C3C3C) : AppColors.hairline),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'A BOOK',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_outline),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const FavoritesScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.5 + (value * 0.5),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.blockLilac.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading books...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceSoft,
                        isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _searchBooks,
                                style: GoogleFonts.inter(fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Search books...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF2C2C2C) : AppColors.canvas,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _selectedTags.isNotEmpty
                                  ? (isDark ? AppColors.blockMint : AppColors.blockLime)
                                  : (isDark ? const Color(0xFF2C2C2C) : AppColors.canvas),
                              shape: BoxShape.circle,
                              boxShadow: _selectedTags.isNotEmpty
                                  ? [
                                      BoxShadow(
                                        color: (isDark ? AppColors.blockMint : AppColors.blockLime)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: _showTagFilter,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ViewModeButton(
                            icon: Icons.grid_view,
                            isSelected: _viewMode == ViewMode.grid,
                            onTap: () => setState(() => _viewMode = ViewMode.grid),
                          ),
                          const SizedBox(width: 8),
                          _ViewModeButton(
                            icon: Icons.view_list,
                            isSelected: _viewMode == ViewMode.list,
                            onTap: () => setState(() => _viewMode = ViewMode.list),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_selectedTags.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text('Filters: ', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                          ..._selectedTags.map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                label: Text(tag, style: GoogleFonts.inter(fontSize: 12)),
                                onDeleted: () {
                                  setState(() {
                                    _selectedTags.remove(tag);
                                    _filterByTags();
                                  });
                                },
                                backgroundColor: isDark ? AppColors.blockMint : AppColors.blockLime,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: _displayedBooks.isEmpty
                      ? Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white12 : AppColors.surfaceSoft,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: isDark ? Colors.white24 : AppColors.ink.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'No books found',
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your filters',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: isDark ? Colors.white54 : AppColors.ink.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : _viewMode == ViewMode.grid
                          ? GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _displayedBooks.length,
                              itemBuilder: (context, index) {
                                return BookCard(
                                  book: _displayedBooks[index],
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => BookDetailScreen(book: _displayedBooks[index])),
                                    ).then((_) => setState(() {}));
                                  },
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _displayedBooks.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: BookListItem(
                                    book: _displayedBooks[index],
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => BookDetailScreen(book: _displayedBooks[index])),
                                      ).then((_) => setState(() {}));
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.blockMint : AppColors.blockLime)
              : (isDark ? const Color(0xFF2C2C2C) : AppColors.canvas),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: isDark ? Colors.white : AppColors.primary, width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.blockMint : AppColors.blockLime)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(icon, size: 24),
      ),
    );
  }
}
