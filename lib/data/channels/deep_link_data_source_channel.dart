import 'package:flutter/services.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_data_source_channel_interface.dart';

class DeepLinkDataSourceChannel implements IDeepLinkDataSourceChannel {
  static const _channel = MethodChannel(
    'br.com.kalebemisael.jogodavelha/deeplink',
  );

  @override
  Future<Map<String, dynamic>?> getPendingRoute() async {
    try {
      final result = await _channel.invokeMethod<Map>('getPendingRoute');
      return result?.cast<String, dynamic>();
    } on PlatformException {
      return null;
    }
  }
}
