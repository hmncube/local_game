import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../di/di.dart';

abstract class BaseCubitWrapper<T> extends Cubit<T> {
  BaseCubitWrapper(super.state) {
    initialize();
  }

  GetIt get inject => getIt;

  void initialize();

  void dispose();

  void emitState(T state) {
    emit(state);
  }

  void emitError(T state, Object error) {
    debugPrint(error.toString());
    emit(state);
  }

  void showLog(dynamic message) {
    debugPrint('[$runtimeType] $message');
  }
}