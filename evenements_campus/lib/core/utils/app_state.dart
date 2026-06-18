import 'package:flutter/material.dart';

class AppState {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static void restartApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MyAppPlaceholder()),
      (route) => false,
    );
  }
}

class MyAppPlaceholder extends StatelessWidget {
  const MyAppPlaceholder({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}