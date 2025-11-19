
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
import 'theme/app_colors.dart';

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
            primaryColor: AppColors.primary,
            brightness: Brightness.light,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: AppColors.white,
            cardColor: AppColors.white,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.white,
              background: AppColors.veryLightGray,
              error: AppColors.error,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 2,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: AppColors.white,
              shadowColor: Colors.black.withOpacity(0.08),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.veryLightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: AppColors.primaryLight,
            brightness: Brightness.dark,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: AppColors.dark,
            cardColor: AppColors.darkGray,
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryLight,
              secondary: AppColors.secondaryLight,
              surface: AppColors.darkGray,
              background: AppColors.dark,
              error: AppColors.error,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.white,
                elevation: 2,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.darkGray,
              foregroundColor: AppColors.white,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: AppColors.darkGray,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.darkGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.mediumGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.mediumGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
              ),
            ),
          ),
          themeMode: themeService.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => LandingPage(),
            '/auth': (context) => AuthPage(),
            '/dashboard': (context) => DashboardPage(),
            '/builder': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final portfolioId = args is String ? args : null;
              return PortfolioBuilderPage(portfolioId: portfolioId);
            },
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
