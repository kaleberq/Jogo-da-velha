import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/tic_tac_toe_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const TicTacToeScreen());
  }
}
