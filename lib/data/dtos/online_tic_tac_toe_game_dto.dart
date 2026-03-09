import 'package:jogo_da_velha/data/models/online_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/winning_line_enum.dart';

/// DTO do estado do jogo online. Responsável por toJson/fromJson (transporte).
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

  /// Cria DTO a partir do modelo (para enviar).
  factory OnlineTicTacToeGameDTO.fromModel(OnlineTicTacToeGameModel model) {
    return OnlineTicTacToeGameDTO(
      board: model.board.map((row) => row.map((c) => c.name).toList()).toList(),
      currentPlayer: model.currentPlayer.name,
      winner: model.winner?.name,
      winningLine: model.winningLine != null
          ? {
              'type': model.winningLine!.type.name,
              'index': model.winningLine!.index,
            }
          : null,
      isGameOver: model.isGameOver,
      scoreX: model.scoreX,
      scoreO: model.scoreO,
      currentRound: model.currentRound,
      maxRounds: model.maxRounds,
    );
  }

  /// Converte DTO para modelo (ao receber).
  OnlineTicTacToeGameModel toModel() {
    final boardModel = board
        .map<List<PlayerEnum>>(
          (row) =>
              row.map<PlayerEnum>((c) => PlayerEnum.values.byName(c)).toList(),
        )
        .toList();

    WinningLineModel? winningLineModel;
    if (winningLine != null) {
      final type = WinningLineEnum.values.byName(
        winningLine!['type'] as String,
      );
      final index = winningLine!['index'] as int?;
      winningLineModel = WinningLineModel(type: type, index: index);
    }

    return OnlineTicTacToeGameModel.fromValues(
      board: boardModel,
      currentPlayer: PlayerEnum.values.byName(currentPlayer),
      winner: winner != null ? PlayerEnum.values.byName(winner!) : null,
      winningLine: winningLineModel,
      isGameOver: isGameOver,
      scoreX: scoreX,
      scoreO: scoreO,
      currentRound: currentRound,
      maxRounds: maxRounds,
    );
  }
}
