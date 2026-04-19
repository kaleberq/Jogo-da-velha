import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/domain/models/host_room_model.dart';
import 'package:jogo_da_velha/domain/models/online_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/score_display_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/components/turn_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_view_model.dart';

class FakeGameRepository implements IGameRepository {
  @override
  set onMessageReceived(Function(String)? callback) {}
  @override
  set onConnectionStatusChanged(Function(String)? callback) {}
  @override
  set onError(Function(String)? callback) {}
  @override
  set onGameStateReceived(void Function(OnlineTicTacToeGameModel)? callback) {}
  @override
  set onRequestMove(void Function(int row, int col)? callback) {}
  @override
  set onResetReceived(void Function()? callback) {}
  @override
  set onNextRoundReceived(void Function()? callback) {}
  @override
  set onConfigReceived(void Function(int maxRounds)? callback) {}

  @override
  Future<String?> startServer() async => null;
  @override
  Future<HostRoomModel> createHostRoom() async => const HostRoomModel();
  @override
  Future<bool> connectToServer({required String ip}) async => true;
  @override
  void disconnect() {}
  @override
  void sendReset() {}
  @override
  void sendNextRound() {}
  @override
  void sendConfig({required int maxRounds}) {}
  @override
  void sendRequestMove(int row, int col) {}
  @override
  void sendCurrentGameState(OnlineTicTacToeGameModel game) {}
}

void main() {
  testWidgets('OnlineGameScreen renders main game widgets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    final viewModel = OnlineGameViewModel(
      playerRole: PlayerRole.host,
      gameRepository: FakeGameRepository(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnlineGameScreen(viewModel: viewModel),
      ),
    );
    await tester.pump();

    expect(find.byType(RoundIndicatorComponent), findsOneWidget);
    expect(find.byType(TurnIndicatorComponent), findsOneWidget);
    expect(find.byType(ScoreDisplayComponent), findsOneWidget);
    expect(find.byType(GameBoardComponent), findsOneWidget);

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  });
}
