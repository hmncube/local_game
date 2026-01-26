import 'package:flutter/material.dart';
import 'package:local_game/presentation/widget/neubrutalism_container.dart';

class NeubrutalismToast extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;

  const NeubrutalismToast({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFFE88328),
    this.icon = Icons.star_rounded,
  });

  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = const Color(0xFFE88328),
    IconData icon = Icons.star_rounded,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => _ToastWidget(
            message: message,
            backgroundColor: backgroundColor,
            icon: icon,
            onDismiss: () => overlayEntry.remove(),
            duration: duration,
          ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return NeubrutalismContainer(
      borderRadius: 20,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: child,
                ),
              );
            },
            child: NeubrutalismToast(
              message: widget.message,
              backgroundColor: widget.backgroundColor,
              icon: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}
