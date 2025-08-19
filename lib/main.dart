import 'package:flutter/material.dart';
import 'package:local_game/core/di/di.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const WordGameApp());
}
