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

class _SwipeKeyboardState extends State<SwipeKeyboard> {
  final Map<String, Rect> _letterPositions = {};
  final Set<String> _swipedLetters = {};
  final List<Offset> _swipePath = [];

  @override
  void initState() {
    super.initState();
    _generateLetterPositions();
  }

  void _generateLetterPositions() {
    _letterPositions.clear();

    final centerX = 150.0;
    final centerY = 100.0;
    final radius = 80.0;
    final count = widget.enabledLetters.length;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i) / count;
      final dx = centerX + radius * cos(angle - pi / 2);
      final dy = centerY + radius * sin(angle - pi / 2);

      _letterPositions[widget.enabledLetters[i]] = Rect.fromCenter(
        center: Offset(dx, dy),
        width: 40,
        height: 40,
      );
    }
  }

  void _handleTouch(Offset position) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _swipedLetters.clear();
        _swipePath.clear();
        _handleTouch(details.localPosition);
      },
      onPanUpdate: (details) {
        _handleTouch(details.localPosition);
      },
      onPanEnd: (details) {
        _swipePath.clear();
        _swipedLetters.clear();
        setState(() {});
      },
      child: SizedBox(
        height: 200,
        width: 300,
        child: CustomPaint(
          painter: SwipeLinePainter(_swipePath),
          child: Stack(
            children:
                _letterPositions.entries.map((entry) {
                  return Positioned(
                    left: entry.value.left,
                    top: entry.value.top,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        entry.key,
                        style: AppTextStyles.tileLetter.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class SwipeLinePainter extends CustomPainter {
  final List<Offset> points;

  SwipeLinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint =
        Paint()
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
