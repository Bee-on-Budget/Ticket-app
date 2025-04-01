import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final _poppinsFont = GoogleFonts.poppins();

final ThemeData themeConfig = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF3D4B3F), // Primary color
  ),

  // Floating Action Button Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3D4B3F), // Dark green
    foregroundColor: Colors.white, // White icon
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3D4B3F),
      // Dark green
      foregroundColor: Colors.white,
      // White text
      iconColor: Colors.white,
      // White icon
      padding: const EdgeInsets.all(25),
      textStyle: GoogleFonts.poppins(
        fontSize: 15,
        color: const Color(0xFF8D8D8D), // Light gray hint text
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.all(20),
    hintStyle: GoogleFonts.poppins(
      fontSize: 15,
      color: const Color(0xFF8D8D8D), // Light gray hint text
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: const Color(0xFF3D4B3F),
        width: 1,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Colors.blueGrey,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Color(0xFF3D4B3F), // Dark green border
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Color(0xFF6B8E4E), // Lighter green border
        width: 2,
      ),
    ),
    prefixIconColor: const Color(0xFF4F4F4F), // Dark gray icon
  ),

  // Dropdown Menu Theme
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      // White background
      elevation: WidgetStateProperty.all(4),
      // Add shadow
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),

  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
    ),
  ),
  fontFamily: _poppinsFont.fontFamily,
  textTheme: TextTheme(
    bodyLarge: _poppinsFont.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF3D4B3F), // Dark gray text
    ),
    labelLarge: _poppinsFont.copyWith(
      fontSize: 18,
      color: const Color(0xFF8D8D8D), // Light gray text
    ),
    titleLarge: _poppinsFont.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF3D4B3F), // Dark green text
    ),
    titleMedium: _poppinsFont.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF161B16), // Dark green Text
    ),
    titleSmall: _poppinsFont.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF161B16), // Dark green Text
    ),
    bodyMedium: _poppinsFont.copyWith(
      fontSize: 15,
      color: const Color(0xFF4F4F4F),
    ),
  ),

  // SnackBar Theme
  snackBarTheme: SnackBarThemeData(
    closeIconColor: const Color(0xFF3D4B3F), // Dark green close icon
    backgroundColor: const Color(0xFFE0F7E9), // Light green background
    contentTextStyle: GoogleFonts.poppins(
      color: const Color(0xFF3D4B3F), // Dark green text
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ),
  ),
);