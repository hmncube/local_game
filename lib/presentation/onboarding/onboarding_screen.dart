import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/onboarding/onboarding_cubit.dart';
import 'package:local_game/presentation/onboarding/onboarding_state.dart';
import 'package:local_game/presentation/widget/app_btn.dart';
import 'package:local_game/presentation/widget/app_option_btn.dart';
import 'package:local_game/presentation/widget/app_text_input.dart';
import 'package:local_game/presentation/widget/error_screen.dart';
import 'package:local_game/presentation/widget/loading_screen.dart';
import 'package:local_game/presentation/widget/neubrutalism_container.dart';
import 'package:local_game/data/model/player_icon_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nicknameController = TextEditingController();
  late AnimationController _bounceController;
  late final OnboardingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<OnboardingCubit>();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.navigateToMap) {
            context.go(Routes.mapScreen.toPath);
          }
        },
        builder: (context, state) {
          if (state.cubitState is CubitLoading) return const LoadingScreen();
          if (state.cubitState is CubitError) return const ErrorScreen();

          const creamBackground = Color(0xFFFFF9E5);
          const darkBorderColor = Color(0xFF2B2118);
          const accentOrange = Color(0xFFE88328);

          return Scaffold(
            backgroundColor: creamBackground,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        const Center(
                          child: Text(
                            'Join the Adventure',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: darkBorderColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: darkBorderColor,
                    thickness: 2,
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const Text(
                            "What's your name?",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: darkBorderColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          NeubrutalismContainer(
                            borderRadius: 50,
                            height: 70,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextField(
                              controller: _nicknameController,
                              onChanged:
                                  (text) => _cubit.onNicknameChanged(text),
                              decoration: const InputDecoration(
                                hintText: 'Type your name...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkBorderColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          const Text(
                            "Pick your language",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: darkBorderColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...state.langauges.map((language) {
                            final isSelected =
                                state.selectedLanguage?.contains(language) ==
                                true;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap:
                                    () => _cubit.onLanguageSelectedChanged(
                                      language,
                                    ),
                                child: NeubrutalismContainer(
                                  backgroundColor:
                                      isSelected ? accentOrange : Colors.white,
                                  borderRadius: 50,
                                  height: 60,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      language.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : darkBorderColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 32),

                          const Text(
                            "Choose your Mascot",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: darkBorderColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMascotCard(
                                state.playerIcons.length > 5
                                    ? state.playerIcons[5] // Owl as 'Birdie'
                                    : null,
                                'Birdie',
                                state.selectedPlayerIcon?.id ==
                                    (state.playerIcons.length > 5
                                        ? state.playerIcons[5].id
                                        : -1),
                                darkBorderColor,
                                accentOrange,
                              ),
                              _buildMascotCard(
                                state.playerIcons.length > 4
                                    ? state.playerIcons[4] // Lion as 'Simba'
                                    : null,
                                'Simba',
                                state.selectedPlayerIcon?.id ==
                                    (state.playerIcons.length > 4
                                        ? state.playerIcons[4].id
                                        : -1),
                                darkBorderColor,
                                accentOrange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Button
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GestureDetector(
                      onTap:
                          state.canProceed ? () => _cubit.saveProfile() : null,
                      child: Opacity(
                        opacity: state.canProceed ? 1.0 : 0.5,
                        child: NeubrutalismContainer(
                          backgroundColor: accentOrange,
                          borderRadius: 50,
                          height: 80,
                          width: double.infinity,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'START ADVENTURE',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.rocket_launch,
                                color: Colors.white,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMascotCard(
    PlayerIconModel? icon,
    String name,
    bool isSelected,
    Color darkBorderColor,
    Color accentOrange,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: icon != null ? () => _cubit.onIconSelected(icon) : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              NeubrutalismContainer(
                borderRadius: 30,
                width: 140,
                height: 140,
                backgroundColor:
                    isSelected ? const Color(0xFFFFE0B2) : Colors.white,
                borderColor: isSelected ? accentOrange : darkBorderColor,
                padding: const EdgeInsets.all(8),
                child:
                    icon != null
                        ? SvgPicture.asset(
                          'assets/svg/${icon.path}.svg',
                          fit: BoxFit.contain,
                        )
                        : const SizedBox(),
              ),
              if (isSelected)
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentOrange,
                      shape: BoxShape.circle,
                      border: Border.all(color: darkBorderColor, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isSelected ? accentOrange : darkBorderColor,
          ),
        ),
      ],
    );
  }
}
