import 'dart:typed_data';

/// Model com os dados da sala hospedada (IP e QR para conexão).
class HostRoomModel {
  final String? ip;
  final Uint8List? qrCodeBytes;

  const HostRoomModel({this.ip, this.qrCodeBytes});
}
