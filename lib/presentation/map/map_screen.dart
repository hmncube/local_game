import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/map/map_cubit.dart';
import 'package:local_game/presentation/map/map_state.dart';

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
        appBar: AppBar(
          title: const Text('Levels'),
        ),
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (cubitState is CubitSuccess) {
              if (state.levels.isEmpty) {
                return const Center(
                  child: Text('No levels found.'),
                );
              }
              return ListView.builder(
                itemCount: state.levels.length,
                itemBuilder: (context, index) {
                  final level = state.levels[index];
                  return InkWell(
                    onTap: () {
                      context.go(Routes.gameScreen.toPath, extra: level.id);
                    },
                    child: ListTile(
                      title: Text('Level ${level.id}'),
                      //subtitle: Text('Difficulty: ${level.difficulty}'),
                      trailing: Text('Points: ${level.points}'),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text('Something went wrong.'),
            );
          },
        ),
      ),
    );
  }
}
