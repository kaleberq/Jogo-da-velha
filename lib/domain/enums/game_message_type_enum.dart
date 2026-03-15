/// Tipo da mensagem de jogo no payload JSON da rede.
enum GameMessageTypeEnum {
  gameState('gameState'),
  requestMove('requestMove'),
  reset('reset'),
  nextRound('nextRound'),
  config('config');

  final String value;

  const GameMessageTypeEnum(this.value);

  static GameMessageTypeEnum? tryParse(String? type) {
    if (type == null) return null;
    for (final e in GameMessageTypeEnum.values) {
      if (e.value == type) return e;
    }
    return null;
  }
}
