import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';

const _channel = MethodChannel('br.com.kalebemisael.jogodavelha/deeplink');

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _lineAnimationController;
  late Animation<double> _lineAnimation;
  final SplashViewModel _viewModel = SplashViewModel();

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

    // Espera a animação de fade terminar antes de começar a animação dos X's
    _animationController.addStatusListener(_startBoardAnimation);

    // Espera a animação do traço terminar para navegar
    _lineAnimationController.addStatusListener(_navigate);

    // Configura callbacks do ViewModel
    _viewModel.onLineAnimationReady = () {
      if (mounted) {
        _lineAnimationController.forward();
      }
    };

    super.initState();
  }

  void _startBoardAnimation(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!mounted) return;
    if (_viewModel.state.hasStartedBoardAnimation) return;

    _viewModel.startBoardAnimation();
  }

  Future<void> _navigate(AnimationStatus status) async {
    if (status != AnimationStatus.completed || !mounted) return;

    try {
      final result = await _channel.invokeMethod<Map>('getPendingRoute');

      if (!mounted) return;

      final deepLink = result?.cast<String, dynamic>();
      final route = _resolveRoute(deepLink);

      if (route == RoutesEnum.localGame && deepLink != null) {
        _navigateToLocalGame(deepLink);
      } else {
        _goToMenu();
      }
    } catch (e) {
      if (!mounted) return;
      _goToMenu();
    }
  }

  RoutesEnum _resolveRoute(Map<String, dynamic>? deepLink) {
    final rawRoute = deepLink?['route'] as String?;
    if (rawRoute == null) return RoutesEnum.menu;

    final normalizedRoute = rawRoute.split('/').last;

    return RoutesEnum.values.firstWhere(
      (e) => e.path.replaceAll('/', '') == normalizedRoute,
      orElse: () => RoutesEnum.menu,
    );
  }

  void _navigateToLocalGame(Map<String, dynamic> deepLink) {
    final maxRounds = deepLink['maxRounds'] as int;
    final timeLimitSeconds = deepLink['timeLimitSeconds'] as int;

    Navigator.of(context).pushReplacementNamed(RoutesEnum.menu.path);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context).pushNamed(
        RoutesEnum.localGame.path,
        arguments: (maxRounds: maxRounds, timeLimitSeconds: timeLimitSeconds),
      );
    });
  }

  void _goToMenu() {
    Navigator.of(context).pushReplacementNamed(RoutesEnum.menu.path);
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_startBoardAnimation);
    _animationController.dispose();
    _lineAnimationController.dispose();
    _viewModel.dispose();
    _channel.setMethodCallHandler(null);
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
                        game: _viewModel.game,
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
