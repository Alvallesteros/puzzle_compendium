import 'package:flutter/material.dart';
import 'package:puzzle_arcade/app_shell.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'puzzle_arcade',
      home: NavigationScreen()
    );
  }
}

