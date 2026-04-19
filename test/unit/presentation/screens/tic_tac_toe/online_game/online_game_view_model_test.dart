import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/domain/models/host_room_model.dart';
import 'package:jogo_da_velha/domain/models/online_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_view_model.dart';

class FakeGameRepository implements IGameRepository {
  Function(String)? messageCallback;
  Function(String)? connectionStatusCallback;
  Function(String)? errorCallback;
  void Function(OnlineTicTacToeGameModel)? gameStateCallback;
  void Function(int, int)? requestMoveCallback;
  void Function()? resetCallback;
  void Function()? nextRoundCallback;
  void Function(int)? configCallback;

  int sendCurrentGameStateCalls = 0;
  ({int row, int col})? sentMove;
  bool disconnectCalled = false;

  @override
  set onMessageReceived(Function(String)? callback) => messageCallback = callback;
  @override
  set onConnectionStatusChanged(Function(String)? callback) =>
      connectionStatusCallback = callback;
  @override
  set onError(Function(String)? callback) => errorCallback = callback;
  @override
  set onGameStateReceived(void Function(OnlineTicTacToeGameModel)? callback) =>
      gameStateCallback = callback;
  @override
  set onRequestMove(void Function(int, int)? callback) =>
      requestMoveCallback = callback;
  @override
  set onResetReceived(void Function()? callback) => resetCallback = callback;
  @override
  set onNextRoundReceived(void Function()? callback) => nextRoundCallback = callback;
  @override
  set onConfigReceived(void Function(int)? callback) => configCallback = callback;

  @override
  Future<bool> connectToServer({required String ip}) async => true;
  @override
  Future<HostRoomModel> createHostRoom() async => const HostRoomModel();
  @override
  void disconnect() => disconnectCalled = true;
  @override
  void sendConfig({required int maxRounds}) {}
  @override
  void sendCurrentGameState(OnlineTicTacToeGameModel game) =>
      sendCurrentGameStateCalls++;
  @override
  void sendNextRound() {}
  @override
  void sendRequestMove(int row, int col) => sentMove = (row: row, col: col);
  @override
  void sendReset() {}
  @override
  Future<String?> startServer() async => null;
}

void main() {
  group('OnlineGameViewModel', () {
    test('host handles requestMove callback and sends updated game state', () {
      final repo = FakeGameRepository();
      final viewModel = OnlineGameViewModel(
        playerRole: PlayerRole.host,
        gameRepository: repo,
      );

      viewModel.game.board[0][0] = PlayerEnum.x;
      viewModel.game.currentPlayer == PlayerEnum.o;
      // Force host to accept guest move now.
      viewModel.setMaxRounds(viewModel.game.maxRounds);
      viewModel.reset();
      viewModel.game.board[0][0] = PlayerEnum.none;
      viewModel.makeMoveWithPlayer(0, 0, PlayerEnum.x);

      repo.requestMoveCallback?.call(1, 1);

      expect(viewModel.game.board[1][1], PlayerEnum.o);
      expect(repo.sendCurrentGameStateCalls, 1);
    });

    test('guest does not process requestMove callback', () {
      final repo = FakeGameRepository();
      final viewModel = OnlineGameViewModel(
        playerRole: PlayerRole.guest,
        gameRepository: repo,
      );

      repo.requestMoveCallback?.call(1, 1);

      expect(viewModel.game.board[1][1], PlayerEnum.none);
      expect(repo.sendCurrentGameStateCalls, 0);
    });

    test('makeMove updates turn to next player', () {
      final repo = FakeGameRepository();
      final viewModel = OnlineGameViewModel(
        playerRole: PlayerRole.host,
        gameRepository: repo,
      );

      viewModel.makeMove(0, 0);

      expect(viewModel.game.board[0][0], PlayerEnum.x);
      expect(viewModel.game.currentPlayer, PlayerEnum.o);
    });

    test('dispose disconnects repository', () {
      final repo = FakeGameRepository();
      final viewModel = OnlineGameViewModel(
        playerRole: PlayerRole.host,
        gameRepository: repo,
      );

      viewModel.dispose();

      expect(repo.disconnectCalled, isTrue);
    });
  });
}
