
  // lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/landing_page.dart';
import 'screens/auth_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/portfolio_builder_page.dart';
import 'screens/templates_page.dart';
import 'screens/public_portfolio_page.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
      ],
      child: ElevareApp(),
    ),
  );
}

class ElevareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elevare - Portfolio Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/auth': (context) => AuthPage(),
        '/dashboard': (context) => DashboardPage(),
        '/builder': (context) => PortfolioBuilderPage(),
        '/templates': (context) => TemplatesPage(),
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
  }
}
