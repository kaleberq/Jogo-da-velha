import 'dart:typed_data';

/// Abstração para geração de QR code.
abstract interface class IQrCodeGeneratorService {
  Future<Uint8List?> generateQr(String data);
}
