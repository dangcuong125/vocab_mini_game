import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const VocabApp());
}

class VocabApp extends StatelessWidget {
  const VocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vocab Mini Game',
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}
