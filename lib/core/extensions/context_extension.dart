import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;
}
