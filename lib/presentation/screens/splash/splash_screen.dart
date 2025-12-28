import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/winning_line.dart';
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/row_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/horizontal_divider_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/winning_line_overlay.dart';

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
  final List<List<PlayerEnum>> _board = List.generate(
    3,
    (_) => List.generate(3, (_) => PlayerEnum.none),
  );
  int _currentIndex = 0;
  Timer? _boardAnimationTimer;
  bool _hasStartedBoardAnimation = false;

  // Posições da diagonal principal
  final List<Map<String, int>> _diagonalPositions = [
    {'row': 0, 'col': 0},
    {'row': 1, 'col': 1},
    {'row': 2, 'col': 2},
  ];

  @override
  void initState() {
    super.initState();
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
  }

  void _startBoardAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        !_hasStartedBoardAnimation &&
        mounted) {
      _hasStartedBoardAnimation = true;
      // Adiciona X's progressivamente na diagonal
      _boardAnimationTimer = Timer.periodic(const Duration(milliseconds: 500), (
        timer,
      ) {
        if (_currentIndex < _diagonalPositions.length && mounted) {
          setState(() {
            final pos = _diagonalPositions[_currentIndex];
            _board[pos['row']!][pos['col']!] = PlayerEnum.x;
            _currentIndex++;
          });
        } else {
          timer.cancel();
          // Inicia a animação do traço quando todos os X's estão na diagonal
          if (mounted) {
            _lineAnimationController.forward();
          }
        }
      });
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
    _boardAnimationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 50,
            children: [
              Stack(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        RowComponent(
                          rowIndex: 0,
                          row: _board[0],
                          onCellTap:
                              ({
                                required int rowIndex,
                                required int columnIndex,
                              }) {},
                        ),
                        const HorizontalDividerComponent(),
                        RowComponent(
                          rowIndex: 1,
                          row: _board[1],
                          onCellTap:
                              ({
                                required int rowIndex,
                                required int columnIndex,
                              }) {},
                        ),
                        const HorizontalDividerComponent(),
                        RowComponent(
                          rowIndex: 2,
                          row: _board[2],
                          onCellTap:
                              ({
                                required int rowIndex,
                                required int columnIndex,
                              }) {},
                        ),
                      ],
                    ),
                  ),
                  if (_currentIndex == _diagonalPositions.length)
                    AnimatedBuilder(
                      animation: _lineAnimation,
                      builder: (context, child) {
                        return WinningLineOverlay(
                          winningLine: WinningLine.diagonalMain(),
                          boardSize: 200,
                          animationProgress: _lineAnimation.value,
                        );
                      },
                    ),
                ],
              ),
              Text(
                'Jogo da Velha',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
