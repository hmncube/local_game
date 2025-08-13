import 'package:equatable/equatable.dart';

abstract class BaseCubitState extends Equatable {}


class CubitInitial extends BaseCubitState {
  @override
  List<Object?> get props => [];
}

class CubitLoading extends BaseCubitState {
  @override
  List<Object?> get props => [];
}

class CubitSuccess<T> extends BaseCubitState {
  final String? message;
  final T? data;

  CubitSuccess({this.message, this.data});

  @override
  List<Object?> get props => [data, message];
}

class CubitError extends BaseCubitState {
  final String message;
  final int code;

  CubitError({this.code = 405, required this.message});

  @override
  List<Object?> get props => [code, message];
}

class CubitLoaded<T> extends BaseCubitState {
  final T? data;
  final String? message;

  CubitLoaded({this.data, this.message});

  @override
  List<Object?> get props => [data, message];
}

class CubitStateFactory {
  static BaseCubitState initial() => CubitInitial();

  static BaseCubitState loading() => CubitLoading();

  static BaseCubitState loaded<T>({String? event, T? data}) =>
      CubitLoaded<T>(message: event, data: data);

  static BaseCubitState success<T>({String? event, T? data}) =>
      CubitSuccess<T>(message: event, data: data);

  static BaseCubitState error({int code = 405, required String message}) =>
      CubitError(code: code, message: message);
}