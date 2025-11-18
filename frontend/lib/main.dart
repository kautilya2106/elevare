
  // lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/landing_page.dart';
import 'screens/auth_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/portfolio_builder_page.dart';
import 'screens/templates_page.dart';
import 'screens/public_portfolio_page.dart';
import 'screens/settings_page.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/theme_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        Provider(create: (_) => ApiService()),
      ],
      child: ElevareApp(),
    ),
  );
}

class ElevareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Elevare - Portfolio Platform',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Color(0xFF667eea),
            brightness: Brightness.light,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Color(0xFF667eea),
            brightness: Brightness.dark,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: Color(0xFF121212),
            cardColor: Color(0xFF1E1E1E),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          themeMode: themeService.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => LandingPage(),
            '/auth': (context) => AuthPage(),
            '/dashboard': (context) => DashboardPage(),
            '/builder': (context) => PortfolioBuilderPage(),
            '/templates': (context) => TemplatesPage(),
            '/settings': (context) => SettingsPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name?.startsWith('/p/') ?? false) {
              final slug = settings.name!.substring(3);
              return MaterialPageRoute(
                builder: (context) => PublicPortfolioPage(slug: slug),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
