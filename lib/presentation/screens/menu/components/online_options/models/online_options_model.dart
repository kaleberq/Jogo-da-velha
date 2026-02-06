import 'dart:typed_data';

class OnlineOptionsModel {
  bool isCreatingServer;
  bool isConnecting;
  bool navigatingToGame;
  Uint8List? qrCodeBytes;

  OnlineOptionsModel({
    this.isCreatingServer = false,
    this.isConnecting = false,
    this.navigatingToGame = false,
    this.qrCodeBytes,
  });

  void resetServerState() {
    isCreatingServer = false;
    qrCodeBytes = null;
  }

  void resetConnectionState() {
    isConnecting = false;
  }

  void reset() {
    isCreatingServer = false;
    isConnecting = false;
    navigatingToGame = false;
    qrCodeBytes = null;
  }
}
