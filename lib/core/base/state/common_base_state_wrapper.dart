import 'package:flutter/material.dart';
import 'package:local_game/core/base/state/toast_type.dart';

abstract class CommonBaseStateWrapper<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  void onInit();
  void onDispose();
  void onPause();
  void onResume();
  void onHide();

  Widget onBuild(BuildContext context, BoxConstraints constraints);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    onInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onDispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        handleAppResume();
        onResume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        handleAppPause();
        onPause();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        handleAppHide();
        onHide();
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void handleAppResume() {}
  void handleAppPause() {}
  void handleAppHide() {}

  void showLog(String message) {
    debugPrint(message);
  }

  void showLoading() {}

  void hideLoading() {}

  void showToast(String message, {ToastType type = ToastType.normal}) {
    final color =
        type == ToastType.normal
            ? null
            : type == ToastType.success
            ? Colors.green
            : type == ToastType.error
            ? Colors.redAccent
            : Colors.yellowAccent;
    final textColor =
        type == ToastType.normal || type == ToastType.success
            ? Colors.white
            : Colors.black;
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: textColor, fontFamily: 'Inter'),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void dismissKeyboard() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }
}
