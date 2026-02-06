import 'package:flutter/services.dart';

class NativeQrGenerator {
  static const _channel = MethodChannel('br.com.kalebemisael.jogodavelha/qr');

  static Future<Uint8List> generate(String data) async {
    final bytes = await _channel.invokeMethod<Uint8List>('generateQr', {
      'data': data,
    });

    if (bytes == null) {
      throw Exception('QR generation failed');
    }

    return bytes;
  }
}
