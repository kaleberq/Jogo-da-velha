import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:jogo_da_velha/domain/interfaces/services/qr_code_generator_service_interface.dart';
import 'package:qr_native_bridge/qr_native_bridge.dart';

/// Implementação de [IQrCodeGeneratorService] usando [QrNativeBridge].
class QrCodeGeneratorService implements IQrCodeGeneratorService {
  @override
  Future<Uint8List?> generateQr(String data) async {
    try {
      return await QrNativeBridge().generateQr(data);
    } catch (e, stackTrace) {
      developer.log(
        'Falha ao gerar QR code',
        name: 'QrCodeGeneratorService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
