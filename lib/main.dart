import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'constants/app_colors.dart';
import 'constants/app_config.dart';
import 'constants/app_dimens.dart';
import 'constants/app_text_styles.dart';
import 'screens/home_screen.dart';
import 'services/app_settings_service.dart';
import 'services/catalog_service.dart';
import 'services/admin_data_service.dart';
import 'services/quotation_storage_service.dart';
import 'services/quotation_save_service.dart';
import 'services/terms_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase FIRST
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  // Sign in anonymously
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
      print('Signed in anonymously');
    } else if (user.isAnonymous) {
      print('Already signed in anonymously');
    } else {
      print('User is already signed in');
    }
  } catch (e) {
    print('Anonymous sign-in error: $e');
  }
  
  // Initialize all services
  await AppSettingsService.instance.init();
  await TermsService.instance.init();
  await AdminDataService.instance.init();
  await QuotationStorageService.instance.init();
  await CatalogService.instance.init();
  await QuotationSaveService.instance.init();
  
  runApp(const SolarQuotationApp());
}

class SolarQuotationApp extends StatelessWidget {
  const SolarQuotationApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? Typography.whiteMountainView : Typography.blackMountainView;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.brandGreen,
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
            onPrimary: Colors.white,
            outline: Colors.white60,
          )
        : ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTextStyles.fontFamily,
      fontFamilyFallback: AppTextStyles.fontFallback,
      scaffoldBackgroundColor: isDark ? const Color(0xFF000000) : null,
      cardColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      dividerColor: isDark ? Colors.white30 : null,
      textTheme: base.copyWith(
        bodyLarge: TextStyle(
          fontSize: AppDimens.formFontSize,
          color: isDark ? Colors.white : Colors.black87,
          fontFamily: AppTextStyles.fontFamily,
          fontFamilyFallback: AppTextStyles.fontFallback,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimens.formFontSize,
          color: isDark ? Colors.white : Colors.black87,
          fontFamily: AppTextStyles.fontFamily,
          fontFamilyFallback: AppTextStyles.fontFallback,
        ),
        titleMedium: TextStyle(
          fontSize: AppDimens.formCardTitle,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
          fontFamily: AppTextStyles.fontFamily,
          fontFamilyFallback: AppTextStyles.fontFallback,
        ),
        titleLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.letterheadGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: isDark ? 1 : 3,
      ),
      listTileTheme: ListTileThemeData(
        textColor: isDark ? Colors.white : Colors.black87,
        iconColor: isDark ? Colors.white70 : Colors.black54,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFDE7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        labelStyle: TextStyle(
          fontSize: AppDimens.formFontSize,
          color: isDark ? Colors.white : AppColors.letterheadGreen,
        ),
        hintStyle: TextStyle(
          fontSize: AppDimens.formFontSize,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? Colors.white54 : Colors.black26,
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.brandGreen, width: 2),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
        ),
      ),
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettingsService.instance.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}