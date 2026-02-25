import 'dart:typed_data';
import 'package:jogo_da_velha/domain/interfaces/services/qr_code_generator_service_interface.dart';
import 'package:qr_native_bridge/qr_native_bridge.dart';

/// Implementação de [IQrCodeGeneratorService] usando [QrNativeBridge].
class QrCodeGeneratorService implements IQrCodeGeneratorService {
  @override
  Future<Uint8List> generateQr(String data) {
    return QrNativeBridge().generateQr(data);
  }
}
