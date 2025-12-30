class MenuModel {
  final bool isCreatingServer;
  final String? serverIP;
  final bool isConnecting;
  final bool navigatingToGame;

  MenuModel({
    this.isCreatingServer = false,
    this.serverIP,
    this.isConnecting = false,
    this.navigatingToGame = false,
  });

  void reset() {
    copyWith(
      isCreatingServer: false,
      serverIP: null,
      isConnecting: false,
      navigatingToGame: false,
    );
  }

  void resetServerState() {
    copyWith(isCreatingServer: false, serverIP: null);
  }

  void resetConnectionState() {
    copyWith(isConnecting: false);
  }

  MenuModel copyWith({
    bool? isCreatingServer,
    String? serverIP,
    bool? isConnecting,
    bool? navigatingToGame,
    bool clearServerIP = false,
  }) {
    return MenuModel(
      isCreatingServer: isCreatingServer ?? this.isCreatingServer,
      serverIP: clearServerIP ? null : (serverIP ?? this.serverIP),
      isConnecting: isConnecting ?? this.isConnecting,
      navigatingToGame: navigatingToGame ?? this.navigatingToGame,
    );
  }
}
