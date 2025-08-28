import 'package:flutter/material.dart';

class LettersKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final List<String> enabledLetters;
  final Color? keyColor;
  final Color? textColor;
  final Color? disabledKeyColor;
  final Color? disabledTextColor;
  final double keyHeight;
  final double keySpacing;

  const LettersKeyboard({
    super.key,
    required this.onKeyPressed,
    this.enabledLetters = const [],
    this.keyColor,
    this.textColor,
    this.disabledKeyColor,
    this.disabledTextColor,
    this.keyHeight = 45.0,
    this.keySpacing = 4.0,
  });

  // QWERTY layout for letters
  final List<List<String>> keyboardLayout = const [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  @override
  Widget build(BuildContext context) {
    print('pundez keyboard');
    print(enabledLetters);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row
        _buildKeyRow(keyboardLayout[0]),
        SizedBox(height: keySpacing),
        
        // Second row
        _buildKeyRow(keyboardLayout[1]),
        SizedBox(height: keySpacing),
        
        // Third row
        _buildKeyRow(keyboardLayout[2]),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String letter) {
    final bool isEnabled = enabledLetters.isEmpty || enabledLetters.contains(letter.toLowerCase());
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: keySpacing / 2),
      child: Material(
        color: isEnabled 
            ? (keyColor ?? Colors.white)
            : (disabledKeyColor ?? Colors.grey[300]),
        borderRadius: BorderRadius.circular(6),
        elevation: isEnabled ? 1 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: isEnabled ? () => onKeyPressed(letter) : null,
          child: Container(
            width: 32,
            height: keyHeight,
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isEnabled 
                    ? (textColor ?? Colors.black87)
                    : (disabledTextColor ?? Colors.grey[500]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage widget
class KeyboardDemo extends StatefulWidget {
  @override
  State<KeyboardDemo> createState() => _KeyboardDemoState();
}

class _KeyboardDemoState extends State<KeyboardDemo> {
  String inputText = '';
  bool showKeyboard = false;
  List<String> enabledLetters = ["I", "F", "T"]; // Example enabled letters

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Letters Keyboard Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tap the text field to show the letters keyboard:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showKeyboard = !showKeyboard;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        inputText.isEmpty ? 'Tap here to type...' : inputText,
                        style: TextStyle(
                          fontSize: 18,
                          color: inputText.isEmpty ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              inputText = '';
                            });
                          },
                          child: const Text('Clear Text'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              enabledLetters = enabledLetters.isEmpty 
                                  ? ["I", "F", "T"] 
                                  : [];
                            });
                          },
                          child: Text(enabledLetters.isEmpty 
                              ? 'Enable I,F,T Only' 
                              : 'Enable All Letters'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    enabledLetters.isEmpty 
                        ? 'All letters enabled' 
                        : 'Enabled letters: ${enabledLetters.join(", ")}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (showKeyboard)
            LettersKeyboard(
              enabledLetters: enabledLetters,
              onKeyPressed: (letter) {
                setState(() {
                  inputText += letter;
                });
              },
              keyColor: Colors.white,
              textColor: Colors.black87,
              disabledKeyColor: Colors.grey[200],
              disabledTextColor: Colors.grey[400],
            ),
        ],
      ),
    );
  }
}
