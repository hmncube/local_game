import 'dart:math';
import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';

class SwipeKeyboard extends StatefulWidget {
  final List<String> enabledLetters;
  final Function(String) onKeyPressed;

  const SwipeKeyboard({
    super.key,
    required this.enabledLetters,
    required this.onKeyPressed,
  });

  @override
  State<SwipeKeyboard> createState() => _SwipeKeyboardState();
}

class _SwipeKeyboardState extends State<SwipeKeyboard>
    with TickerProviderStateMixin {
  final Map<String, Rect> _letterPositions = {};
  final Set<String> _swipedLetters = {};
  final List<Offset> _swipePath = [];
  List<String> _keyboardLetters = [];
  
  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _keyboardLetters = widget.enabledLetters;
    
    // Initialize animation controllers
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Setup animations
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _generateLetterPositions();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _generateLetterPositions() {
    _letterPositions.clear();

    final centerX = 150.0;
    final centerY = 100.0;
    final radius = 80.0;
    final count = _keyboardLetters.length;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i) / count;
      final dx = centerX + radius * cos(angle - pi / 2);
      final dy = centerY + radius * sin(angle - pi / 2);

      _letterPositions[_keyboardLetters[i]] = Rect.fromCenter(
        center: Offset(dx, dy),
        width: 40,
        height: 40,
      );
    }
  }

  void _handleTouch(Offset position) {
    if (_isAnimating) return; // Don't handle touch during animation
    
    _swipePath.add(position);

    for (var entry in _letterPositions.entries) {
      if (entry.value.contains(position) &&
          !_swipedLetters.contains(entry.key)) {
        _swipedLetters.add(entry.key);
        widget.onKeyPressed(entry.key);
        _swipePath.add(entry.value.center);
      }
    }

    setState(() {});
  }

  void _randomiseLetters() async {
    if (_isAnimating) return; // Prevent multiple animations
    
    setState(() {
      _isAnimating = true;
    });

    // Start both animations
    _scaleController.forward();
    await _rotationController.forward();
    
    // Shuffle letters and regenerate positions
    _keyboardLetters.shuffle();
    _generateLetterPositions();
    
    // Reset animations
    await _scaleController.reverse();
    _rotationController.reset();
    
    setState(() {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onPanStart: (details) {
            if (_isAnimating) return;
            _swipedLetters.clear();
            _swipePath.clear();
            _handleTouch(details.localPosition);
          },
          onPanUpdate: (details) {
            if (_isAnimating) return;
            _handleTouch(details.localPosition);
          },
          onPanEnd: (details) {
            if (_isAnimating) return;
            _swipePath.clear();
            _swipedLetters.clear();
            setState(() {});
          },
          child: SizedBox(
            height: 200,
            width: 300,
            child: CustomPaint(
              painter: SwipeLinePainter(_swipePath),
              child: AnimatedBuilder(
                animation: Listenable.merge([_rotationController, _scaleController]),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Stack(
                        children: _letterPositions.entries.map((entry) {
                          return Positioned(
                            left: entry.value.left,
                            top: entry.value.top,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: _isAnimating ? 100 : 0),
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: _isAnimating
                                  ? BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    )
                                  : null,
                              child: AnimatedOpacity(
                                opacity: _isAnimating ? 0.7 : 1.0,
                                duration: Duration(milliseconds: 200),
                                child: Text(
                                  entry.key,
                                  style: AppTextStyles.tileLetter.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _randomiseLetters,
          child: AnimatedRotation(
            turns: _isAnimating ? 1.0 : 0.0,
            duration: Duration(milliseconds: 800),
            child: Icon(
              Icons.refresh,
              color: _isAnimating ? Colors.grey : Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}

class SwipeLinePainter extends CustomPainter {
  final List<Offset> points;

  SwipeLinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SwipeLinePainter oldDelegate) =>
      oldDelegate.points != points;
}
