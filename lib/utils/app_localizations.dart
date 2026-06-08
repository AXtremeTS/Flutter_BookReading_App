import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('vi', ''),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Splash & Auth
      'app_name': 'BOOK HAVEN',
      'app_subtitle': 'Your reading sanctuary',
      'welcome_back': 'Welcome Back',
      'login_subtitle': 'Login to continue reading',
      'username': 'Username',
      'password': 'Password',
      'login': 'Login',
      'register': 'Register',
      'create_account': 'Create Account',
      'join_community': 'Join our reading community',
      'confirm_password': 'Confirm Password',
      'dont_have_account': 'Don\'t have an account? ',
      'demo_credentials': 'Demo Credentials:',
      
      // Home
      'search_books': 'Search books...',
      'filter_by_tags': 'Filter by Tags',
      'clear': 'Clear',
      'apply_filters': 'Apply Filters',
      'filters': 'Filters: ',
      'no_books_found': 'No books found',
      'favorite_books': 'Favorite Books',
      
      // Book Detail
      'by_author': 'by',
      'description': 'Description',
      'start_reading': 'Start Reading',
      'continue_reading': 'Continue Reading',
      'chapters': 'Chapters',
      
      // Reading
      'chapter_of': 'Chapter %s of %s',
      'previous': 'Previous',
      'next': 'Next',
      'text_size': 'Text Size',
      'adjust_text_size': 'Adjust reading text size',
      'done': 'Done',
      
      // Profile
      'profile': 'Profile',
      'books_read': 'Books Read',
      'favorites': 'Favorites',
      'reading_history': 'Reading History',
      'settings': 'Settings',
      'about': 'About',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      
      // Settings
      'language': 'Language',
      'select_language': 'Select Language',
      'english': 'English',
      'vietnamese': 'Tiếng Việt',
      'theme': 'Theme',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'app_preferences': 'App preferences',
      
      // View Mode
      'grid_view': 'Grid View',
      'list_view': 'List View',
      
      // Empty States
      'no_favorites_yet': 'No favorite books yet',
      'start_adding_favorites': 'Start adding books to your favorites',
      'no_history_yet': 'No reading history yet',
      'start_reading_history': 'Start reading to build your history',
      
      // Errors
      'invalid_credentials': 'Invalid username or password',
      'username_exists': 'Username already exists',
      'settings_coming_soon': 'Settings coming soon',
    },
    'vi': {
      // Splash & Auth
      'app_name': 'NHÀ SÁCH',
      'app_subtitle': 'Thiên đường đọc sách của bạn',
      'welcome_back': 'Chào Mừng Trở Lại',
      'login_subtitle': 'Đăng nhập để tiếp tục đọc',
      'username': 'Tên đăng nhập',
      'password': 'Mật khẩu',
      'login': 'Đăng Nhập',
      'register': 'Đăng Ký',
      'create_account': 'Tạo Tài Khoản',
      'join_community': 'Tham gia cộng đồng đọc sách',
      'confirm_password': 'Xác nhận mật khẩu',
      'dont_have_account': 'Chưa có tài khoản? ',
      'demo_credentials': 'Tài khoản demo:',
      
      // Home
      'search_books': 'Tìm kiếm sách...',
      'filter_by_tags': 'Lọc theo thẻ',
      'clear': 'Xóa',
      'apply_filters': 'Áp dụng bộ lọc',
      'filters': 'Bộ lọc: ',
      'no_books_found': 'Không tìm thấy sách',
      'favorite_books': 'Sách Yêu Thích',
      
      // Book Detail
      'by_author': 'bởi',
      'description': 'Mô tả',
      'start_reading': 'Bắt Đầu Đọc',
      'continue_reading': 'Tiếp Tục Đọc',
      'chapters': 'Các Chương',
      
      // Reading
      'chapter_of': 'Chương %s của %s',
      'previous': 'Trước',
      'next': 'Tiếp',
      'text_size': 'Cỡ chữ',
      'adjust_text_size': 'Điều chỉnh cỡ chữ đọc',
      'done': 'Xong',
      
      // Profile
      'profile': 'Hồ Sơ',
      'books_read': 'Đã Đọc',
      'favorites': 'Yêu Thích',
      'reading_history': 'Lịch Sử Đọc',
      'settings': 'Cài Đặt',
      'about': 'Về Ứng Dụng',
      'logout': 'Đăng Xuất',
      'logout_confirm': 'Bạn có chắc chắn muốn đăng xuất?',
      'cancel': 'Hủy',
      
      // Settings
      'language': 'Ngôn ngữ',
      'select_language': 'Chọn ngôn ngữ',
      'english': 'English',
      'vietnamese': 'Tiếng Việt',
      'theme': 'Giao diện',
      'light_mode': 'Sáng',
      'dark_mode': 'Tối',
      'app_preferences': 'Tùy chỉnh ứng dụng',
      
      // View Mode
      'grid_view': 'Lưới',
      'list_view': 'Danh Sách',
      
      // Empty States
      'no_favorites_yet': 'Chưa có sách yêu thích',
      'start_adding_favorites': 'Thêm sách vào danh sách yêu thích',
      'no_history_yet': 'Chưa có lịch sử đọc',
      'start_reading_history': 'Bắt đầu đọc để xây dựng lịch sử',
      
      // Errors
      'invalid_credentials': 'Tên đăng nhập hoặc mật khẩu không đúng',
      'username_exists': 'Tên đăng nhập đã tồn tại',
      'settings_coming_soon': 'Cài đặt sẽ sớm ra mắt',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appName => translate('app_name');
  String get appSubtitle => translate('app_subtitle');
  String get welcomeBack => translate('welcome_back');
  String get loginSubtitle => translate('login_subtitle');
  String get username => translate('username');
  String get password => translate('password');
  String get login => translate('login');
  String get register => translate('register');
  String get createAccount => translate('create_account');
  String get joinCommunity => translate('join_community');
  String get confirmPassword => translate('confirm_password');
  String get dontHaveAccount => translate('dont_have_account');
  String get demoCredentials => translate('demo_credentials');
  String get searchBooks => translate('search_books');
  String get filterByTags => translate('filter_by_tags');
  String get clear => translate('clear');
  String get applyFilters => translate('apply_filters');
  String get filters => translate('filters');
  String get noBooksFound => translate('no_books_found');
  String get favoriteBooks => translate('favorite_books');
  String get byAuthor => translate('by_author');
  String get description => translate('description');
  String get startReading => translate('start_reading');
  String get continueReading => translate('continue_reading');
  String get chapters => translate('chapters');
  String chapterOf(String current, String total) => translate('chapter_of').replaceAll('%s', current).replaceFirst('%s', total);
  String get previous => translate('previous');
  String get next => translate('next');
  String get textSize => translate('text_size');
  String get adjustTextSize => translate('adjust_text_size');
  String get done => translate('done');
  String get profile => translate('profile');
  String get booksRead => translate('books_read');
  String get favorites => translate('favorites');
  String get readingHistory => translate('reading_history');
  String get settings => translate('settings');
  String get about => translate('about');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logout_confirm');
  String get cancel => translate('cancel');
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get english => translate('english');
  String get vietnamese => translate('vietnamese');
  String get theme => translate('theme');
  String get lightMode => translate('light_mode');
  String get darkMode => translate('dark_mode');
  String get appPreferences => translate('app_preferences');
  String get gridView => translate('grid_view');
  String get listView => translate('list_view');
  String get noFavoritesYet => translate('no_favorites_yet');
  String get startAddingFavorites => translate('start_adding_favorites');
  String get noHistoryYet => translate('no_history_yet');
  String get startReadingHistory => translate('start_reading_history');
  String get invalidCredentials => translate('invalid_credentials');
  String get usernameExists => translate('username_exists');
  String get settingsComingSoon => translate('settings_coming_soon');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
