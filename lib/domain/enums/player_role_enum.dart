/// Papel do jogador na partida online: host (cria a sala) ou guest (entra na sala).
enum PlayerRole {
  host,
  guest;

  bool get isHost => this == PlayerRole.host;
  bool get isGuest => this == PlayerRole.guest;
}
