import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';
import 'services/settings_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().loadSettings();
  await Supabase.initialize(
    url: 'https://tllgztcfzbvhbistlulc.supabase.co',
    anonKey: 'sb_publishable_1fCH3wVHcFq_udrsMj8TVw_wh0_U4Qi',
  );

  runApp(const BookReadingApp());
}

class BookReadingApp extends StatefulWidget {
  const BookReadingApp({super.key});

  @override
  State<BookReadingApp> createState() => _BookReadingAppState();
}

class _BookReadingAppState extends State<BookReadingApp> {
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _settingsService.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reading',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _settingsService.themeMode,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },      
    );
  }
}

