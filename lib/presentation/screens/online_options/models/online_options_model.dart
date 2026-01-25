class OnlineOptionsModel {
  bool isCreatingServer;
  bool isConnecting;
  String? serverIP;
  bool navigatingToGame;

  OnlineOptionsModel({
    this.isCreatingServer = false,
    this.isConnecting = false,
    this.serverIP,
    this.navigatingToGame = false,
  });

  void resetServerState() {
    isCreatingServer = false;
    serverIP = null;
  }

  void resetConnectionState() {
    isConnecting = false;
  }

  void reset() {
    isCreatingServer = false;
    isConnecting = false;
    serverIP = null;
    navigatingToGame = false;
  }
}
