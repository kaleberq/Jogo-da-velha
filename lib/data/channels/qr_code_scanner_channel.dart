import 'package:flutter/services.dart';

class NativeQrScannerChannel {
  static const _channel = MethodChannel(
    'br.com.kalebemisael.jogodavelha/qr_scanner',
  );

  /// Abre o scanner nativo de QR code e retorna o valor escaneado
  static Future<String?> scan() async {
    try {
      final result = await _channel.invokeMethod<String>('scanQr');
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'USER_CANCELLED') {
        return null; // Usuário cancelou
      }
      throw Exception('Erro ao escanear QR code: ${e.message}');
    }
  }
}
