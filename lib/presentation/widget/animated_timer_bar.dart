import 'package:flutter/material.dart';

class AnimatedTimerBar extends StatefulWidget {
  final double value;
  final double height;

  const AnimatedTimerBar({
    super.key,
    required this.value,
    this.height = 30,
  });

  @override
  State<AnimatedTimerBar> createState() => _AnimatedTimerBarState();
}

class _AnimatedTimerBarState extends State<AnimatedTimerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(AnimatedTimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start pulsing when entering danger zone
    if (widget.value <= 0.2 && oldWidget.value > 0.2) {
      _pulseController.repeat(reverse: true);
    } else if (widget.value > 0.2) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getColor(double progress) {
    if (progress > 0.5) return Colors.green;
    if (progress > 0.2) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          tween: ColorTween(
            end: _getColor(widget.value),
          ),
          builder: (context, color, _) {
            // Add pulse effect in danger zone
            final pulseColor = widget.value <= 0.2
                ? Color.lerp(
                    color,
                    Colors.red.shade700,
                    _pulseController.value * 0.3,
                  )
                : color;

            return LinearProgressIndicator(
              value: widget.value,
              color: pulseColor,
              backgroundColor: pulseColor?.withOpacity(0.2),
              minHeight: widget.height,
              borderRadius: BorderRadius.circular(16),
            );
          },
        );
      },
    );
  }
}