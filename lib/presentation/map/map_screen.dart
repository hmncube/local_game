import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/constants/app_values.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/game_system/points_management.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/map/map_cubit.dart';
import 'package:local_game/presentation/map/map_state.dart';
import 'package:local_game/presentation/widget/game_top_bar.dart';
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
              return Scaffold(
                body: Stack(
                  children: [
                    SizedBox(
                      height: double.infinity,
                      child: SvgPicture.asset(
                        AppAssets.backgroundSvg,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white54,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 42.0),
                          child: SizedBox(
                            height: 60,
                            child: GameTopBar(
                              points: state.userModel?.totalScore ?? 0,
                              hints: state.userModel?.hints ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: state.levels.length,
                            itemBuilder: (context, index) {
                              final level = state.levels[index];
                              final isCompleted = level.status == 1;
                              final isUnLocked = true;//unLocked.id == level.id;
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
                                  //todo unloack completed level animatio
                                  !isUnLocked
                                      ? null
                                      : context.go(
                                        _getTypeScreenLocation(level.type),
                                        extra: level.id,
                                      );
                                },
                                difficulty: level.difficulty,
                                isUnLocked:
                                    level.status == AppValues.levelDone ||
                                    isUnLocked,
                              );
                            },
                          ),
                        ),
                      ],
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

  const LevelButton({
    super.key,
    required this.levelId,
    required this.isCompleted,
    required this.onTap,
    required this.difficulty,
    required this.type,
    required this.stars,
    required this.isUnLocked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 70,
                width: 100,
                child: Stack(
                  children: [
                    SvgPicture.asset(_getTypeSvg(type)),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$levelId',
                        style: AppTextStyles.heading1.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !isUnLocked,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white54,
                    ),
                    child: Icon(Icons.lock),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => SvgPicture.asset(
                  index < stars ? AppAssets.filledStarSvg : AppAssets.starSvg,
                  height: 35,
                  width: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeSvg(int type) {
    switch (type) {
      case AppValues.wordLink:
        return AppAssets.linkSvg;
      case AppValues.wordMatch:
        return AppAssets.matchSvg;
      default:
        return AppAssets.fnderSvg;
    }
  }
}
