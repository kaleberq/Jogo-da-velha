import 'dart:math';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/winning_line_enum.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';

class OnlineTicTacToeGameModel {
  static final Random _random = Random();
  final List<List<PlayerEnum>> board;
  final PlayerEnum currentPlayer;
  final PlayerEnum? winner;
  final WinningLineModel? winningLine;
  final bool isGameOver;
  final int scoreX;
  final int scoreO;
  final int currentRound;
  final int maxRounds;

  OnlineTicTacToeGameModel({int? maxRounds})
    : board = List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none)),
      currentPlayer = _random.nextBool() ? PlayerEnum.x : PlayerEnum.o,
      winner = null,
      winningLine = null,
      isGameOver = false,
      scoreX = 0,
      scoreO = 0,
      currentRound = 1,
      maxRounds = maxRounds ?? 5;

  OnlineTicTacToeGameModel._internal({
    required this.board,
    required this.currentPlayer,
    required this.winner,
    required this.winningLine,
    required this.isGameOver,
    required this.scoreX,
    required this.scoreO,
    required this.currentRound,
    required this.maxRounds,
  });

  /// Construtor para reconstruir o estado a partir de valores.
  factory OnlineTicTacToeGameModel.fromValues({
    required List<List<PlayerEnum>> board,
    required PlayerEnum currentPlayer,
    PlayerEnum? winner,
    WinningLineModel? winningLine,
    required bool isGameOver,
    required int scoreX,
    required int scoreO,
    required int currentRound,
    required int maxRounds,
  }) {
    return OnlineTicTacToeGameModel._internal(
      board: board,
      currentPlayer: currentPlayer,
      winner: winner,
      winningLine: winningLine,
      isGameOver: isGameOver,
      scoreX: scoreX,
      scoreO: scoreO,
      currentRound: currentRound,
      maxRounds: maxRounds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board
          .map((row) => row.map((c) => c.name).toList())
          .toList(),
      'currentPlayer': currentPlayer.name,
      'winner': winner?.name,
      'winningLine': winningLine != null
          ? {
              'type': winningLine!.type.name,
              'index': winningLine!.index,
            }
          : null,
      'isGameOver': isGameOver,
      'scoreX': scoreX,
      'scoreO': scoreO,
      'currentRound': currentRound,
      'maxRounds': maxRounds,
    };
  }

  factory OnlineTicTacToeGameModel.fromJson(Map<String, dynamic> json) {
    final boardList = json['board'] as List;
    final board = boardList
        .map<List<PlayerEnum>>((row) => (row as List)
            .map<PlayerEnum>((c) => PlayerEnum.values.byName(c as String))
            .toList())
        .toList();

    WinningLineModel? winningLine;
    final wl = json['winningLine'];
    if (wl != null && wl is Map) {
      final type = WinningLineEnum.values.byName(wl['type'] as String);
      final index = wl['index'] as int?;
      winningLine = WinningLineModel(type: type, index: index);
    }

    return OnlineTicTacToeGameModel.fromValues(
      board: board,
      currentPlayer: PlayerEnum.values.byName(json['currentPlayer'] as String),
      winner: json['winner'] != null
          ? PlayerEnum.values.byName(json['winner'] as String)
          : null,
      winningLine: winningLine,
      isGameOver: json['isGameOver'] as bool,
      scoreX: json['scoreX'] as int,
      scoreO: json['scoreO'] as int,
      currentRound: json['currentRound'] as int,
      maxRounds: json['maxRounds'] as int,
    );
  }

  OnlineTicTacToeGameModel copyWith({
    List<List<PlayerEnum>>? board,
    PlayerEnum? currentPlayer,
    PlayerEnum? winner,
    WinningLineModel? winningLine,
    bool clearWinner = false,
    bool clearWinningLine = false,
    bool? isGameOver,
    int? scoreX,
    int? scoreO,
    int? currentRound,
    int? maxRounds,
  }) {
    return OnlineTicTacToeGameModel._internal(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: clearWinner ? null : (winner ?? this.winner),
      winningLine: clearWinningLine ? null : (winningLine ?? this.winningLine),
      isGameOver: isGameOver ?? this.isGameOver,
      scoreX: scoreX ?? this.scoreX,
      scoreO: scoreO ?? this.scoreO,
      currentRound: currentRound ?? this.currentRound,
      maxRounds: maxRounds ?? this.maxRounds,
    );
  }
}
