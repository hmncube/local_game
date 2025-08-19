import 'package:injectable/injectable.dart';
import '../../data/database_provider.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  DatabaseProvider get databaseProvider => DatabaseProvider();
}