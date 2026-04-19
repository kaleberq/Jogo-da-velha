import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/constants/network_message_constants.dart';

void main() {
  test('NetworkMessageConstants.peerConnected uses expected protocol value', () {
    expect(NetworkMessageConstants.peerConnected, 'CONNECTED');
  });
}
