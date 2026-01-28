import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_design_system/themes/ds_theme.dart';
import 'package:jogo_da_velha/core/dependency_container.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';
import 'package:jogo_da_velha/presentation/screens/local_options/local_options.dart';
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';
import 'package:jogo_da_velha/presentation/screens/online_options/online_options.dart';
import 'package:jogo_da_velha/presentation/screens/online_options/online_options_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_view_model.dart';

const _channel = MethodChannel('br.com.kalebemisael.jogodavelha/deeplink');

// Busca a rota pendente na inicialização (app fechado).
Future<Map<String, dynamic>?> _getInitialDeepLink() async {
  try {
    final result = await _channel.invokeMethod<Map>('getPendingRoute');
    return result?.cast<String, dynamic>();
  } on PlatformException {
    // Se der erro (ex: o método não existe no nativo ainda), retorna nulo.
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Busca a rota inicial uma única vez antes do app rodar.
  final initialDeepLink = await _getInitialDeepLink();

  runApp(MyApp(initialDeepLink: initialDeepLink));
}

class MyApp extends StatefulWidget {
  final Map<String, dynamic>? initialDeepLink;

  const MyApp({super.key, this.initialDeepLink});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Registra o handler para receber chamadas do nativo quando o app já está aberto.
    //_channel.setMethodCallHandler(_handleDeepLink);

    // Se o app foi aberto por um deep link (inicialização a frio),
    // agenda a navegação para depois do primeiro frame ser construído.
    // if (widget.initialDeepLink != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _navigateTo(widget.initialDeepLink!);
    //   });
    // }
  }

  // // Lida com deep links recebidos enquanto o app está em execução (em background).
  // Future<void> _handleDeepLink(MethodCall call) async {
  //   if (call.method == 'handleDeepLink') {
  //     final args = call.arguments as Map<dynamic, dynamic>?;
  //     if (args != null) {
  //       _navigateTo(args.cast<String, dynamic>());
  //     }
  //   }
  // }

  // Lógica de navegação centralizada para ser usada por ambos os fluxos.
  // void _navigateTo(Map<String, dynamic> pending) {
  //   final route = pending['route'] as String?;
  //   if (route == null) return;
  //
  //   // Garante que o navigator está pronto antes de tentar navegar.
  //   if (_navKey.currentState == null) return;
  //
  //   if (route == RoutesEnum.localGame.path) {
  //     final maxRounds = pending['maxRounds'] as int? ?? 5;
  //     final timeLimit = pending['timeLimit'] as int? ?? 10;
  //     _navKey.currentState?.pushNamed(
  //       route,
  //       arguments: (maxRounds: maxRounds, timeLimitSeconds: timeLimit),
  //     );
  //   } else {
  //     _navKey.currentState?.pushNamed(route);
  //   }
  // }

  @override
  void dispose() {
    // Limpa o handler para evitar vazamentos de memória.
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      theme: DSTheme.light(),
      darkTheme: DSTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: widget.initialDeepLink != null
          ? RoutesEnum.localGame.path
          : RoutesEnum.splash.path,
      routes: {
        RoutesEnum.splash.path: (context) => const SplashScreen(),
        RoutesEnum.menu.path: (context) => const MenuScreen(),
        RoutesEnum.localOptions.path: (context) => const LocalOptions(),
        RoutesEnum.onlineOptions.path: (context) => OnlineOptions(
          viewModel: OnlineOptionsViewModel(
            gameRepository: DependencyContainer.getGameRepository(),
          ),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == RoutesEnum.localGame.path) {
          // Se arguments é null mas temos um deep link inicial, usa os dados do deep link
          int maxRounds;
          int timeLimitSeconds;

          if (settings.arguments == null && widget.initialDeepLink != null) {
            // Deep link inicial - extrai do initialDeepLink
            maxRounds = widget.initialDeepLink!['maxRounds'] as int;
            timeLimitSeconds =
                widget.initialDeepLink!['timeLimitSeconds'] as int;
          } else {
            // Navegação interna - usa os arguments passados
            final args =
                settings.arguments as ({int maxRounds, int timeLimitSeconds});
            maxRounds = args.maxRounds;
            timeLimitSeconds = args.timeLimitSeconds;
          }

          return MaterialPageRoute(
            builder: (_) => LocalGameScreen(
              viewModel: LocalGameViewModel(
                maxRounds: maxRounds,
                timeLimitSeconds: timeLimitSeconds,
              ),
            ),
          );
        } else if (settings.name == RoutesEnum.onlineGame.path) {
          final args = settings.arguments as ({bool isHost});

          return MaterialPageRoute(
            builder: (_) => OnlineGameScreen(
              viewModel: OnlineGameViewModel(
                isHost: args.isHost,
                gameRepository: DependencyContainer.getGameRepository(),
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}
