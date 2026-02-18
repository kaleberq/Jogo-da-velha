import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';

class SplashScreen extends StatefulWidget {
  final SplashViewModel viewModel;

  const SplashScreen({required this.viewModel, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _lineAnimationController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineAnimationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    _animationController.addStatusListener(_startBoardAnimation);

    _lineAnimationController.addStatusListener(_navigate);

    widget.viewModel.onLineAnimationReady = () {
      if (mounted) {
        _lineAnimationController.forward();
      }
    };

    super.initState();
  }

  void _startBoardAnimation(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!mounted) return;
    if (widget.viewModel.state.hasStartedBoardAnimation) return;

    widget.viewModel.startBoardAnimation();
  }

  Future<void> _navigate(AnimationStatus status) async {
    if (status != AnimationStatus.completed) return;

    widget.viewModel.navigate(context);
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_startBoardAnimation);
    _animationController.dispose();
    _lineAnimationController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: DSColors.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: DSSpacing.xxl,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double size = constraints.maxWidth / 2;

                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: DSColors.white.withAlpha(200),
                            offset: const Offset(2, 2),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: GameBoardComponent(
                        game: widget.viewModel.game,
                        winningLineAnimation: _lineAnimation,
                      ),
                    );
                  },
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
