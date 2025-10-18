import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/presentation/widget/app_text_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Game Onboarding',
      theme: ThemeData(primarySwatch: Colors.purple, fontFamily: 'ComicNeue'),
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nicknameController = TextEditingController();
  String? _selectedAnimal;
  int _selectedLanguage = 1;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  final List<Map<String, dynamic>> _animals = [
    {'name': 'Cat', 'emoji': '🐱', 'color': Colors.orange},
    {'name': 'Dog', 'emoji': '🐶', 'color': Colors.brown},
    {'name': 'Panda', 'emoji': '🐼', 'color': Colors.black},
    {'name': 'Fox', 'emoji': '🦊', 'color': Colors.deepOrange},
    {'name': 'Lion', 'emoji': '🦁', 'color': Colors.amber},
    {'name': 'Unicorn', 'emoji': '🦄', 'color': Colors.pink},
  ];

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'flag': '🇬🇧'},
    {'name': 'Español', 'flag': '🇪🇸'},
    {'name': 'Français', 'flag': '🇫🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    return _nicknameController.text.isNotEmpty && _selectedAnimal != null;
  }

  void _handleStart() {
    if (_canProceed()) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.purple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                '🎉 Welcome!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Text(
                'Nickname: ${_nicknameController.text}\n'
                'Animal: $_selectedAnimal\n'
                'Language: ${_languages[_selectedLanguage - 1]['name']}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Let\'s Play!',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: SvgPicture.asset(AppAssets.backgroundSvg, fit: BoxFit.fill),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SvgPicture.asset(AppAssets.mavaraSvg),
                  Text(
                    'Create your profile',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: AppTextInput(
                      onTextChanged: (String text) {
                        print('New text');
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    '🐾 Choose Your Animal',
                    style: AppTextStyles.heading1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const SizedBox(height: 20),

                  // Language Selection
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌍 Select Language (1-3)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(3, (index) {
                            final langIndex = index + 1;
                            final isSelected = _selectedLanguage == langIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedLanguage = langIndex;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 100,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? Colors.purple : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey.shade300,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  boxShadow:
                                      isSelected
                                          ? [
                                            BoxShadow(
                                              color: Colors.purple.withOpacity(
                                                0.5,
                                              ),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                          : [],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _languages[index]['flag']!,
                                      style: const TextStyle(fontSize: 35),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '$langIndex',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.purple,
                                      ),
                                    ),
                                    Text(
                                      _languages[index]['name']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Start Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _canProceed() ? _handleStart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _canProceed() ? Colors.green : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: _canProceed() ? 8 : 0,
                      ),
                      child: Text(
                        _canProceed()
                            ? '🚀 Start Playing!'
                            : 'Complete All Steps',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
