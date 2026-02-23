/// Fluxo da tela de opções online (etapas possíveis).
/// Substitui múltiplas flags booleanas por uma máquina de estados explícita.
enum OnlineOptionsFlowEnum {
  /// Inicial: pode criar sala ou conectar.
  idle,

  /// Criando servidor (startServer em andamento).
  creatingServer,

  /// Servidor criado e QR disponível (ou falha ao gerar QR, mas servidor ok).
  serverReady,

  /// Conectando a um servidor (connectToServer em andamento).
  connecting,

  /// Conectado e deve navegar para o jogo.
  connectedNavigating,
}
