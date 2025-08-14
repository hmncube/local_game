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

import '../../data/local_provider.dart' as _i1063;
import '../../presentation/splash/splash_cubit.dart' as _i447;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i1063.LocalProvider>(() => _i1063.LocalProvider());
  gh.factory<_i447.SplashCubit>(
    () => _i447.SplashCubit(gh<_i1063.LocalProvider>()),
  );
  return getIt;
}
