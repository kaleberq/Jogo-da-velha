import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/score_display_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';

void main() {
  testWidgets('LocalGameScreen renders main game widgets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    final viewModel = LocalGameViewModel(maxRounds: 5, timeLimitSeconds: 10);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LocalGameScreen(viewModel: viewModel),
      ),
    );
    await tester.pump();

    expect(find.byType(RoundIndicatorComponent), findsOneWidget);
    expect(find.byType(ScoreDisplayComponent), findsOneWidget);
    expect(find.byType(GameBoardComponent), findsOneWidget);

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  });
}
