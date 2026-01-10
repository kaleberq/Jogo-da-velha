import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_view_model.dart';
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
  final SplashViewModel _viewModel = SplashViewModel();

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

    // Configura callbacks do ViewModel
    _viewModel.onLineAnimationReady = () {
      if (mounted) {
        _lineAnimationController.forward();
      }
    };

    super.initState();
  }

  void _startBoardAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        !_viewModel.state.hasStartedBoardAnimation &&
        mounted) {
      _viewModel.startBoardAnimation();
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
    _animationController.dispose();
    _lineAnimationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: DSColors.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: DSSpacing.xxl,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GameBoardComponent(
                      game: _viewModel.game,
                      winningLineAnimation: _lineAnimation,
                      lineSize: 200,
                    ),
                  ),
                ),
                Text(
                  context.l10n.appTitle,
                  style: DSTypographySemiBold.labelXLarge.copyWith(
                    color: DSColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
