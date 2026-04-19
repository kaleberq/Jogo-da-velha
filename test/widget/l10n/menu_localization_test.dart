import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';

void main() {
  Future<void> pumpMenuScreen(
    WidgetTester tester, {
    required Locale locale,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MenuScreen(),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('MenuScreen localization', () {
    testWidgets('shows Portuguese strings when locale is pt', (tester) async {
      await pumpMenuScreen(tester, locale: const Locale('pt'));

      expect(find.text('Escolha um modo de jogo'), findsOneWidget);
      expect(find.text('Jogo Local'), findsOneWidget);
      expect(find.text('Jogo Online'), findsOneWidget);
    });

    testWidgets('shows English strings when locale is en', (tester) async {
      await pumpMenuScreen(tester, locale: const Locale('en'));

      expect(find.text('Choose a game mode.'), findsOneWidget);
      expect(find.text('Local game'), findsOneWidget);
      expect(find.text('Online Play'), findsOneWidget);
    });
  });
}
