import 'package:flutter/material.dart';
import 'package:local_game/presentation/widget/animated_button.dart';

class AppAnimatedIcon extends StatelessWidget {
  final IconData icon;
  const AppAnimatedIcon({super.key, required this.icon,});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showAbandonGameDialog(context);
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  void _showAbandonGameDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _AnimatedDialog(animation: animation);
      },
    );
  }
}

class _AnimatedDialog extends StatefulWidget {
  final Animation<double> animation;

  const _AnimatedDialog({required this.animation});

  @override
  State<_AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<_AnimatedDialog>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _colorController;
  late Animation<double> _waveAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Color transition controller
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Wave effect animation
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOutCubic),
    );

    // Fluid color transition
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black.withOpacity(0.85),
    ).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOutQuart),
    );

    // Scale animation for the dialog content
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: widget.animation, curve: Curves.elasticOut),
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _waveController.forward();
    _colorController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.animation,
        _waveAnimation,
        _colorAnimation,
      ]),
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Animated background overlay with wave effect
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.3),
                    radius: 1.2 * _waveAnimation.value,
                    colors: [
                      _colorAnimation.value ?? Colors.transparent,
                      (_colorAnimation.value ?? Colors.transparent).withOpacity(
                        0.9 * _waveAnimation.value,
                      ),
                      (_colorAnimation.value ?? Colors.transparent).withOpacity(
                        0.6 * _waveAnimation.value,
                      ),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),

              // Dialog content
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Do you want to abandon the game? You will lose all your progress",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // No Button
                              AnimatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                backgroundColor: Colors.grey[700]!,
                                child: const Text("No"),
                              ),
                              // Yes Button
                              AnimatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Add your logic here for when user confirms abandoning the game
                                },
                                backgroundColor: Colors.red[600]!,
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
