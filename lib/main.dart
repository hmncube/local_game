import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/sound/sound_manager.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await configureDependencies();
  await getIt<SoundManager>().playBackgroundMusic();
  runApp(const WordGameApp());
}
