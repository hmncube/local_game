import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/constants/app_values.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/game_system/points_management.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/map/map_cubit.dart';
import 'package:local_game/presentation/map/map_state.dart';
import 'package:local_game/presentation/widget/game_top_bar.dart';
import 'package:local_game/presentation/widget/loading_screen.dart';
import 'package:local_game/presentation/widget/neubrutalism_container.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapCubit _cubit;

  @override
  void initState() {
    _cubit = getIt<MapCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const creamBackground = Color(0xFFFFF9E5);
    const darkBorderColor = Color(0xFF2B2118);
    const accentOrange = Color(0xFFE88328);

    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        backgroundColor: creamBackground,
        body: BlocConsumer<MapCubit, MapState>(
          listener: (context, state) {
            if (state.cubitState is CubitError) {
              final errorState = state.cubitState as CubitError;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorState.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubitState = state.cubitState;
            if (cubitState is CubitLoading) {
              return const LoadingScreen();
            } else if (cubitState is CubitSuccess) {
              if (state.levels.isEmpty) {
                return const Center(child: Text('No levels found.'));
              }
              final unLocked = state.levels.firstWhere(
                (level) => level.status == 0,
                orElse: () => state.levels.last,
              );
              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: GameTopBar(
                        points: state.userModel?.totalScore ?? 0,
                        hints: state.userModel?.hints ?? 0,
                        showHome: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(
                      height: 1,
                      color: darkBorderColor,
                      thickness: 2,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select a Level',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: darkBorderColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 24.0,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: state.levels.length,
                        itemBuilder: (context, index) {
                          final level = state.levels[index];
                          final isCompleted = level.status == 1;
                          final isUnLocked =
                              unLocked.id == level.id || isCompleted;
                          return LevelButton(
                            levelId: level.id,
                            type: level.type,
                            isCompleted: isCompleted,
                            stars:
                                level.status == AppValues.levelDone
                                    ? PointsManagement.calculateStars(
                                      level.points,
                                    )
                                    : 0,
                            onTap: () {
                              if (isUnLocked) {
                                context.go(
                                  _getTypeScreenLocation(level.type),
                                  extra: level.id,
                                );
                              }
                            },
                            difficulty: level.difficulty,
                            isUnLocked: isUnLocked,
                            darkBorderColor: darkBorderColor,
                            accentOrange: accentOrange,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }

  String _getTypeScreenLocation(int type) {
    switch (type) {
      case AppValues.wordLink:
        return Routes.gameScreen.toPath;
      case AppValues.wordMatch:
        return Routes.similarWords.toPath;
      default:
        return Routes.wordSearch.toPath;
    }
  }
}

class LevelButton extends StatelessWidget {
  final int levelId;
  final bool isCompleted;
  final VoidCallback onTap;
  final int difficulty;
  final int type;
  final int stars;
  final bool isUnLocked;
  final Color darkBorderColor;
  final Color accentOrange;

  const LevelButton({
    super.key,
    required this.levelId,
    required this.isCompleted,
    required this.onTap,
    required this.difficulty,
    required this.type,
    required this.stars,
    required this.isUnLocked,
    required this.darkBorderColor,
    required this.accentOrange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: NeubrutalismContainer(
              borderRadius: 20,
              borderWidth: 3,
              shadowOffset: const Offset(0, 4),
              backgroundColor: isUnLocked ? Colors.white : Colors.grey[300]!,
              borderColor: isUnLocked ? darkBorderColor : Colors.grey,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$levelId',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color:
                                isUnLocked ? darkBorderColor : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          _getTypeIcon(type),
                          size: 16,
                          color: isUnLocked ? accentOrange : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  if (!isUnLocked)
                    const Center(
                      child: Icon(Icons.lock, color: Colors.white70, size: 32),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                size: 20,
                color: index < stars ? accentOrange : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(int type) {
    switch (type) {
      case AppValues.wordLink:
        return Icons.link;
      case AppValues.wordMatch:
        return Icons.compare_arrows;
      default:
        return Icons.search;
    }
  }
}
