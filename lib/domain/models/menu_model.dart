class MenuModel {
  bool isCreatingServer;
  String? serverIP;
  bool isConnecting;
  bool navigatingToGame;

  MenuModel({
    this.isCreatingServer = false,
    this.serverIP,
    this.isConnecting = false,
    this.navigatingToGame = false,
  });

  void reset() {
    isCreatingServer = false;
    serverIP = null;
    isConnecting = false;
    navigatingToGame = false;
  }

  void resetServerState() {
    isCreatingServer = false;
    serverIP = null;
  }

  void resetConnectionState() {
    isConnecting = false;
  }
}
