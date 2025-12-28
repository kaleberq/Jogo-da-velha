import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/row_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/horizontal_divider_component.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => const MenuScreen()),
        // );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 50,
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
                      row: [PlayerEnum.x, PlayerEnum.none, PlayerEnum.none],
                      onCellTap:
                          ({
                            required int rowIndex,
                            required int columnIndex,
                          }) {},
                    ),
                    const HorizontalDividerComponent(),
                    RowComponent(
                      rowIndex: 1,
                      row: [PlayerEnum.none, PlayerEnum.x, PlayerEnum.none],
                      onCellTap:
                          ({
                            required int rowIndex,
                            required int columnIndex,
                          }) {},
                    ),
                    const HorizontalDividerComponent(),
                    RowComponent(
                      rowIndex: 2,
                      row: [PlayerEnum.none, PlayerEnum.none, PlayerEnum.x],
                      onCellTap:
                          ({
                            required int rowIndex,
                            required int columnIndex,
                          }) {},
                    ),
                  ],
                ),
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
