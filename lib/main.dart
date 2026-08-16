import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_theme.dart';
import 'core/network/supabase_client.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isAuthenticated = false;
  try {
    await SupabaseService.initialize();
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = prefs.getBool('is_authenticated') ?? false;
  } catch (_) {}

  runApp(
    ProviderScope(
      child: EducateSetuSalesApp(initialAuthenticated: isAuthenticated),
    ),
  );
}

class EducateSetuSalesApp extends StatelessWidget {
  final bool initialAuthenticated;
  const EducateSetuSalesApp({super.key, required this.initialAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EducateSetu Sales Agent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: initialAuthenticated ? const MainLayoutScreen() : const LoginScreen(),
    );
  }
}
