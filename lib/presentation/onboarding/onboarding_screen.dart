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
          return (state.cubitState is CubitLoading)
              ? LoadingScreen()
              : (state.cubitState is CubitError)
              ? ErrorScreen()
              : Scaffold(
                body: Stack(
                  children: [
                    SizedBox(
                      height: double.infinity,
                      child: SvgPicture.asset(
                        AppAssets.backgroundSvg,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Column(
                                children: [
                                  SvgPicture.asset(AppAssets.mavaraSvg),
                                  Text(
                                    'Create your profile',
                                    style: AppTextStyles.heading1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AppTextInput(
                                      onTextChanged: (String text) {
                                        _cubit.onNicknameChanged(text);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '🐾 Choose Your Animal',
                                    style: AppTextStyles.heading1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  GridView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1,
                                          crossAxisSpacing: 1,
                                          mainAxisSpacing: 1,
                                        ),
                                    itemCount: 6,
                                    itemBuilder: (context, index) {
                                      final playerIcon =
                                          state.playerIcons[index];
                                      final isSelected =
                                          playerIcon.id ==
                                          state.selectedPlayerIcon?.id;
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            _cubit.onIconSelected(playerIcon);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(185),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                width: isSelected ? 3 : 1,
                                              ),
                                              boxShadow:
                                                  isSelected
                                                      ? [
                                                        BoxShadow(
                                                          color: Colors.purple
                                                              .withOpacity(0.5),
                                                          blurRadius: 10,
                                                          spreadRadius: 2,
                                                        ),
                                                      ]
                                                      : [],
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/svg/${playerIcon.path}.svg',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '🌍 Select Language (1-3)',
                                    style: AppTextStyles.heading1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        state.langauges.map((language) {
                                          final isSelected =
                                              state.selectedLanguage?.contains(
                                                language,
                                              ) ==
                                              true;
                                          return Flexible(
                                            child: AppOptionBtn(
                                              onClick: () {
                                                _cubit
                                                    .onLanguageSelectedChanged(
                                                      language,
                                                    );
                                              },
                                              title: language.name,
                                              isSelected: isSelected,
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Button at the bottom
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: AppBtn(
                            onClick: () {
                              _cubit.saveProfile();
                            },
                            title: 'Save',
                            isEnabled: state.canProceed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
        },
      ),
    );
  }
}
