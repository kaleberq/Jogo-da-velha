import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/data/channels/deep_link_data_source_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('br.com.kalebemisael.jogodavelha/deeplink');
  final deepLinkDataSource = DeepLinkDataSourceChannel();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('DeepLinkDataSourceChannel', () {
    test('returns pending route when method channel succeeds', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'getPendingRoute');
            return {'route': '/menu', 'source': 'deeplink'};
          });

      final result = await deepLinkDataSource.getPendingRoute();

      expect(result, isNotNull);
      expect(result!['route'], '/menu');
      expect(result['source'], 'deeplink');
    });

    test('returns null when method channel throws PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(code: 'ERROR');
          });

      final result = await deepLinkDataSource.getPendingRoute();

      expect(result, isNull);
    });
  });
}
