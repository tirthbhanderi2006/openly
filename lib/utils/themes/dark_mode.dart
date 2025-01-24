
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ThemeData darkMode=ThemeData(
//     colorScheme: ColorScheme.light(
//         background: Colors.grey.shade900,
//         primary: Colors.grey.shade600,
//         secondary: Colors.grey.shade700,
//         tertiary: Colors.grey.shade800,
//         inversePrimary: Colors.grey.shade300
//     ),
//     fontFamily: GoogleFonts.poppins().fontFamily,
// );

ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme(
        brightness: Brightness.dark,
        background: Color(0xFF2C2A29), // Dark background
        primary: Color(0xFFC0BDB8),    // Primary
        secondary: Color(0xFF7A7B7A),  // Secondary
        tertiary: Color(0xFFA8A8A8),   // Tertiary
        inversePrimary: Color(0xFFD3D3D3), // Inverse primary
        error: Colors.red,
        onBackground: Colors.white,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onTertiary: Colors.black,
        onError: Colors.white,
        surface: Color(0xFF4B4A48), // Surface color
        onSurface: Colors.white,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
);