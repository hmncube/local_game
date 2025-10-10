import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/map/map_cubit.dart';
import 'package:local_game/presentation/map/map_state.dart';
import 'package:local_game/presentation/widget/loading_screen.dart';

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
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
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
              return LoadingScreen();
            } else if (cubitState is CubitSuccess) {
              if (state.levels.isEmpty) {
                return const Center(child: Text('No levels found.'));
              }
              final unLocked = state.levels.firstWhere(
                (level) => level.status == 0,
              );
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.0, // Make squares
                  ),
                  itemCount: state.levels.length,
                  itemBuilder: (context, index) {
                    final level = state.levels[index];
                    final isCompleted = level.status == 1;
                    final isUnLocked = unLocked.id == level.id;
                    return LevelButton(
                      levelId: level.id,
                      isCompleted: isCompleted,
                      onTap: () {
                        !isUnLocked
                            ? null
                            : context.go(
                              Routes.wordSearch.toPath,
                              extra: level.id,
                            );
                      },
                      difficulty: level.difficulty,
                      isUnLocked: isUnLocked,
                    );
                  },
                ),
              );
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }
}

class LevelButton extends StatelessWidget {
  final int levelId;
  final bool isCompleted;
  final VoidCallback onTap;
  final int difficulty;
  final bool isUnLocked;

  const LevelButton({
    super.key,
    required this.levelId,
    required this.isCompleted,
    required this.onTap,
    required this.difficulty,
    required this.isUnLocked,
  });

  // Helper function to determine difficulty color
  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppTheme.accentGreen; // Easy
      case 2:
        return AppTheme.primaryGold; // Moderate
      case 3:
        return AppTheme.secondaryRed; // Hard
      default:
        return Colors.grey; // Default color
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor(difficulty);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.correctTile : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppTheme.emptyTileBorder, // Add border
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Difficulty Indicator (colored dot)
            Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                color: difficultyColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Level $levelId',
              style: AppTextStyles.body.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color:
                    isCompleted
                        ? Colors.white
                        : Colors.black, // Adjust text color
              ),
            ),
            const SizedBox(height: 4.0),
            Icon(
              isCompleted
                  ? Icons.check_circle
                  : isUnLocked
                  ? Icons.lock_open
                  : Icons.lock,
              color: isCompleted ? Colors.white : AppTheme.notInWordTile,
            ),
          ],
        ),
      ),
    );
  }
}
