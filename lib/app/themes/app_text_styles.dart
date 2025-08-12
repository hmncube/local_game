import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.handlee(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle heading2 = GoogleFonts.handlee(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle body = GoogleFonts.handlee(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle tileLetter = GoogleFonts.handlee(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.0,
  );

  static TextStyle keyboardKey = GoogleFonts.handlee(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static TextStyle splashTitle = GoogleFonts.handlee(
    fontSize: 50.0,
    fontWeight: FontWeight.bold,
  );

  static TextStyle splashSubtitle = GoogleFonts.handlee(
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
  );
}