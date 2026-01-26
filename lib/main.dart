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

Future<String?> _getPendingRoute() async {
  try {
    return await _channel.invokeMethod<String>('getPendingRoute');
  } on PlatformException {
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final route = await _getPendingRoute();
  runApp(MyApp(initialRoute: route ?? RoutesEnum.splash.path));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _getPendingRoute().then((r) {
      if (r != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navKey.currentState?.pushNamed(r);
        });
      }
    });
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
      initialRoute: widget.initialRoute,
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
          final args =
              settings.arguments as ({int maxRounds, int timeLimitSeconds});

          return MaterialPageRoute(
            builder: (_) => LocalGameScreen(
              viewModel: LocalGameViewModel(
                maxRounds: args.maxRounds,
                timeLimitSeconds: args.timeLimitSeconds,
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
