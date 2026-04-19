import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';

void main() {
  testWidgets('MenuScreen renders game mode options', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MenuScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byIcon(Icons.phone_android), findsOneWidget);
    expect(find.byIcon(Icons.wifi), findsOneWidget);
  });
}
