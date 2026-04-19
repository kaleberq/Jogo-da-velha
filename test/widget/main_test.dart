import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';
import 'package:jogo_da_velha/main.dart';
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_screen.dart';

void main() {
  group('MyApp', () {
    testWidgets('configures localization delegates and supported locales', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(
        materialApp.localizationsDelegates,
        AppLocalizations.localizationsDelegates,
      );
      expect(materialApp.supportedLocales, AppLocalizations.supportedLocales);
    });

    testWidgets('contains splash and menu named routes', (tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.routes?.containsKey(RoutesEnum.splash.path), isTrue);
      expect(materialApp.routes?.containsKey(RoutesEnum.menu.path), isTrue);

      final splashBuilder = materialApp.routes![RoutesEnum.splash.path]!;
      final menuBuilder = materialApp.routes![RoutesEnum.menu.path]!;
      final context = tester.element(find.byType(MaterialApp));

      expect(splashBuilder(context), isA<SplashScreen>());
      expect(menuBuilder(context), isA<MenuScreen>());
    });

    testWidgets('generates local and online game routes', (tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final onGenerateRoute = materialApp.onGenerateRoute!;

      final localRoute = onGenerateRoute(
        const RouteSettings(
          name: '/local-game',
          arguments: (maxRounds: 7, timeLimitSeconds: 20),
        ),
      );
      final onlineRoute = onGenerateRoute(
        const RouteSettings(
          name: '/online-game',
          arguments: (playerRole: PlayerRole.host),
        ),
      );

      expect(localRoute, isA<MaterialPageRoute<dynamic>>());
      expect(onlineRoute, isA<MaterialPageRoute<dynamic>>());

      expect(
        (localRoute! as MaterialPageRoute<dynamic>).builder(
          tester.element(find.byType(MaterialApp)),
        ),
        isA<LocalGameScreen>(),
      );
      expect(
        (onlineRoute! as MaterialPageRoute<dynamic>).builder(
          tester.element(find.byType(MaterialApp)),
        ),
        isA<OnlineGameScreen>(),
      );
    });
  });
}
