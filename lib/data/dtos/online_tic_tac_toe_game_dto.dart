/// DTO do estado do jogo online. Responsável apenas por toJson/fromJson (transporte).
class OnlineTicTacToeGameDTO {
  final List<List<String>> board;
  final String currentPlayer;
  final String? winner;
  final Map<String, dynamic>? winningLine;
  final bool isGameOver;
  final int scoreX;
  final int scoreO;
  final int currentRound;
  final int maxRounds;

  const OnlineTicTacToeGameDTO({
    required this.board,
    required this.currentPlayer,
    this.winner,
    this.winningLine,
    required this.isGameOver,
    required this.scoreX,
    required this.scoreO,
    required this.currentRound,
    required this.maxRounds,
  });

  /// Serializa para envio pela rede.
  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'currentPlayer': currentPlayer,
      'winner': winner,
      'winningLine': winningLine,
      'isGameOver': isGameOver,
      'scoreX': scoreX,
      'scoreO': scoreO,
      'currentRound': currentRound,
      'maxRounds': maxRounds,
    };
  }

  /// Desserializa a partir do JSON recebido.
  factory OnlineTicTacToeGameDTO.fromJson(Map<String, dynamic> json) {
    final boardList = json['board'] as List;
    final board = boardList
        .map<List<String>>(
          (row) => (row as List).map<String>((c) => c as String).toList(),
        )
        .toList();

    Map<String, dynamic>? winningLine;
    final wl = json['winningLine'];
    if (wl != null && wl is Map) {
      winningLine = Map<String, dynamic>.from(wl);
    }

    return OnlineTicTacToeGameDTO(
      board: board,
      currentPlayer: json['currentPlayer'] as String,
      winner: json['winner'] as String?,
      winningLine: winningLine,
      isGameOver: json['isGameOver'] as bool,
      scoreX: json['scoreX'] as int,
      scoreO: json['scoreO'] as int,
      currentRound: json['currentRound'] as int,
      maxRounds: json['maxRounds'] as int,
    );
  }
}
