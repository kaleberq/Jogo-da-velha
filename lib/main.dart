import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_design_system/themes/ds_theme.dart';
import 'package:jogo_da_velha/core/dependency_container.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
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
      initialRoute: RoutesEnum.splash.path,
      routes: {
        RoutesEnum.splash.path: (context) => const SplashScreen(),
        RoutesEnum.menu.path: (context) => const MenuScreen(),
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
