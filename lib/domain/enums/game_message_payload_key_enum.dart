/// Chaves do payload JSON das mensagens de jogo na rede.
enum GameMessagePayloadKeyEnum {
  /// Chave que indica o tipo da mensagem (gameState, requestMove, reset, etc.).
  type('type');

  final String key;

  const GameMessagePayloadKeyEnum(this.key);
}
