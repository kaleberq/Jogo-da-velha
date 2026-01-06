import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/direction_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/screens/splash/models/splash_model.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _lineAnimationController;
  late Animation<double> _lineAnimation;
  final TicTacToeGameModel _game = TicTacToeGameModel();
  final SplashModel _state = SplashModel();

  // Posições da diagonal principal
  final List<Map<DirectionEnum, int>> _diagonalPositions = [
    {DirectionEnum.row: 0, DirectionEnum.col: 0},
    {DirectionEnum.row: 1, DirectionEnum.col: 1},
    {DirectionEnum.row: 2, DirectionEnum.col: 2},
  ];

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineAnimationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Espera a animação de fade terminar antes de começar a animação dos X's
    _animationController.addStatusListener(_startBoardAnimation);

    // Espera a animação do traço terminar para navegar
    _lineAnimationController.addStatusListener(_navigateToMenu);

    super.initState();
  }

  void _startBoardAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        !_state.hasStartedBoardAnimation &&
        mounted) {
      _state.hasStartedBoardAnimation = true;
      // Adiciona X's progressivamente na diagonal
      _state.boardAnimationTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (timer) {
          if (_state.currentIndex < _diagonalPositions.length && mounted) {
            setState(() {
              final pos = _diagonalPositions[_state.currentIndex];
              _game.board[pos[DirectionEnum.row]!][pos[DirectionEnum.col]!] =
                  PlayerEnum.x;
              _state.incrementIndex();
            });
          } else {
            timer.cancel();
            // Configura a linha de vitória e inicia a animação do traço
            if (mounted) {
              setState(() {
                _game.winningLine = WinningLineModel.diagonalMain();
              });
              _lineAnimationController.forward();
            }
          }
        },
      );
    }
  }

  void _navigateToMenu(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_startBoardAnimation);
    _lineAnimationController.removeStatusListener(_navigateToMenu);
    _animationController.dispose();
    _lineAnimationController.dispose();
    _state.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SizedBox(
            width: 350,
            height: 350,
            child: ClipRect(
              child: Transform.scale(
                scale: 0.8, // Escala baseada no board interno (300x300)
                alignment: Alignment.center,
                child: GameBoardComponent(
                  game: _game,
                  winningLineAnimation: _lineAnimation,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
