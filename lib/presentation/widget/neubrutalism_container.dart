import 'package:flutter/material.dart';

class NeubrutalismContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NeubrutalismContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFF2B2118),
    this.borderWidth = 4.0,
    this.borderRadius = 30.0,
    this.shadowOffset = const Offset(0, 6),
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Transform.translate(
        offset: Offset(0, -shadowOffset.dy),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
