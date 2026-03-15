/// Mensagens de controle de conexão trocadas pela rede.
enum ConnectionMessageEnum {
  disconnected('DISCONNECTED'),
  serverConnected('SERVER_CONNECTED'),
  clientConnected('CLIENT_CONNECTED'),
  connected('CONNECTED');

  final String value;

  const ConnectionMessageEnum(this.value);

  static ConnectionMessageEnum? tryParse(String message) {
    for (final e in ConnectionMessageEnum.values) {
      if (e.value == message) return e;
    }
    return null;
  }
}
