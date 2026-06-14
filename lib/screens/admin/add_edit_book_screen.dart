import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../utils/app_colors.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;
  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookService _bookService = BookService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  
  String? _selectedImagePath;
  bool _isFromFile = false;
  bool _isHidden = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _descriptionController = TextEditingController(text: widget.book?.description ?? '');
    _tagsController = TextEditingController(text: widget.book?.tags.join(', ') ?? '');
    _selectedImagePath = widget.book?.coverImage;
    _isFromFile = widget.book?.isFromFile ?? false;
    _isHidden = widget.book?.isHidden ?? false;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        _isFromFile = true;
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ảnh bìa')),
        );
        return;
      }

      setState(() => _isSaving = true);

      final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      final book = Book(
        id: widget.book?.id ?? '0',
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        coverImage: _selectedImagePath!,
        rating: widget.book?.rating ?? 0.0,
        tags: tags,
        chapters: widget.book?.chapters ?? [],
        isHidden: _isHidden,
        isFromFile: _isFromFile,
      );

      bool success;
      if (widget.book == null) {
        success = await _bookService.addBook(book);
      } else {
        success = await _bookService.updateBook(book);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi lưu sách. Vui lòng thử lại.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Thêm Sách Mới' : 'Sửa Sách'),
        actions: [
          IconButton(
            icon: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check), 
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _isSaving ? null : _pickImage,
                    child: Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _isFromFile 
                                  ? Image.file(File(_selectedImagePath!), fit: BoxFit.cover)
                                  : Image.asset(_selectedImagePath!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Chọn ảnh bìa', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _authorController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Tác giả',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập tác giả' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagsController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Tags (phân tách bằng dấu phẩy)',
                    border: OutlineInputBorder(),
                    helperText: 'Ví dụ: Action, Adventure, Fantasy',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Ẩn sách này'),
                  subtitle: const Text('Người dùng thường sẽ không thấy sách bị ẩn'),
                  value: _isHidden,
                  onChanged: _isSaving ? null : (v) => setState(() => _isHidden = v),
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Lưu Sách', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
