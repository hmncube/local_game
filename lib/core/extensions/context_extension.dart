import 'package:flutter/material.dart';
import 'package:local_game/core/base/state/toast_type.dart';

extension ContextExtension on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;
  void showToast(String message, {ToastType type = ToastType.normal}) {
    final color =
        type == ToastType.normal
            ? null
            : type == ToastType.success
            ? Colors.green
            : type == ToastType.error
            ? Colors.redAccent
            : Colors.yellowAccent;
    final textColor =
        type == ToastType.normal || type == ToastType.success
            ? Colors.white
            : Colors.black;
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: textColor, fontFamily: 'Inter'),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
