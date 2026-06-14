class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator or web
  static const String baseUrl = 'http://10.0.2.2:5271/api';
  
  static const String auth = '$baseUrl/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String books = '$baseUrl/books';
  static const String categories = '$baseUrl/categories';
  static const String reviews = '$baseUrl/reviews';
  static const String admin = '$baseUrl/admin';
}
