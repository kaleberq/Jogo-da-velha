import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/models/network_connection_model.dart';

void main() {
  group('NetworkConnectionModel', () {
    test('starts disconnected by default', () {
      final model = NetworkConnectionModel();

      expect(model.status, ConnectionStatusEnum.disconnected);
      expect(model.errorMessage, isNull);
    });

    test('accepts custom status and error message', () {
      final model = NetworkConnectionModel(
        status: ConnectionStatusEnum.error,
        errorMessage: 'connection failed',
      );

      expect(model.status, ConnectionStatusEnum.error);
      expect(model.errorMessage, 'connection failed');
    });
  });
}
