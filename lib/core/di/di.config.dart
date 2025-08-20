// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sqflite/sqflite.dart' as _i779;

import '../../data/dao/level_dao.dart' as _i0;
import '../../data/database_provider.dart' as _i90;
import '../../data/local_provider.dart' as _i1063;
import '../../presentation/map/map_cubit.dart' as _i621;
import '../../presentation/splash/splash_cubit.dart' as _i447;
import 'di_module.dart' as _i211;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final appModule = _$AppModule();
  final registerModule = _$RegisterModule();
  await gh.factoryAsync<_i779.Database>(
    () => appModule.database,
    preResolve: true,
  );
  gh.lazySingleton<_i90.DatabaseProvider>(
    () => registerModule.databaseProvider,
  );
  gh.lazySingleton<_i1063.LocalProvider>(() => _i1063.LocalProvider());
  gh.factory<_i447.SplashCubit>(
    () => _i447.SplashCubit(
      gh<_i1063.LocalProvider>(),
      gh<_i90.DatabaseProvider>(),
    ),
  );
  gh.factory<_i0.LevelDao>(() => _i0.LevelDao(gh<_i90.DatabaseProvider>()));
  gh.factory<_i621.MapCubit>(() => _i621.MapCubit(gh<_i0.LevelDao>()));
  return getIt;
}

class _$AppModule extends _i211.AppModule {}

class _$RegisterModule extends _i291.RegisterModule {}
