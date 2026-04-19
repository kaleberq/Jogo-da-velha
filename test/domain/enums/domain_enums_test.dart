import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/enums/connection_message_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_type_enum.dart';
import 'package:jogo_da_velha/domain/enums/online_options_flow_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';

void main() {
  group('ConnectionMessageEnum.tryParse', () {
    test('returns enum when message is valid', () {
      expect(
        ConnectionMessageEnum.tryParse('SERVER_CONNECTED'),
        ConnectionMessageEnum.serverConnected,
      );
    });

    test('returns null when message is invalid', () {
      expect(ConnectionMessageEnum.tryParse('UNKNOWN'), isNull);
    });
  });

  group('GameMessageTypeEnum.tryParse', () {
    test('returns enum when value is valid', () {
      expect(
        GameMessageTypeEnum.tryParse('requestMove'),
        GameMessageTypeEnum.requestMove,
      );
    });

    test('returns null when value is null or invalid', () {
      expect(GameMessageTypeEnum.tryParse(null), isNull);
      expect(GameMessageTypeEnum.tryParse('invalid'), isNull);
    });
  });

  group('PlayerRole getters', () {
    test('isHost and isGuest match enum variant', () {
      expect(PlayerRole.host.isHost, isTrue);
      expect(PlayerRole.host.isGuest, isFalse);
      expect(PlayerRole.guest.isHost, isFalse);
      expect(PlayerRole.guest.isGuest, isTrue);
    });
  });

  group('Routes and flow enums', () {
    test('routes have expected paths', () {
      expect(RoutesEnum.splash.path, '/');
      expect(RoutesEnum.menu.path, '/menu');
      expect(RoutesEnum.localGame.path, '/local-game');
      expect(RoutesEnum.onlineGame.path, '/online-game');
    });

    test('online flow enum keeps expected order', () {
      expect(
        OnlineOptionsFlowEnum.values,
        [
          OnlineOptionsFlowEnum.idle,
          OnlineOptionsFlowEnum.creatingServer,
          OnlineOptionsFlowEnum.serverReady,
          OnlineOptionsFlowEnum.connecting,
          OnlineOptionsFlowEnum.connectedNavigating,
        ],
      );
    });
  });
}
