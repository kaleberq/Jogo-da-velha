import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/dialogs/final_score_dialog.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/current_player_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/score_display_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_banner_component.dart';

class LocalGameScreen extends StatefulWidget {
  const LocalGameScreen({super.key});

  @override
  State<LocalGameScreen> createState() => _LocalGameScreenState();
}

class _LocalGameScreenState extends State<LocalGameScreen>
    with TickerProviderStateMixin {
  String? _roundEndMessage;
  PlayerEnum? _roundWinner;
  late AnimationController _winningLineAnimationController;
  late Animation<double> _winningLineAnimation;

  TicTacToeGameModel game = TicTacToeGameModel();

  @override
  void initState() {
    super.initState();
    _winningLineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _winningLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _winningLineAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  void onConfigUpdate(int maxRounds, TicTacToeGameModel newGame) {
    setState(() {
      game = newGame;
    });
  }

  void onMaxRoundsChanged(int maxRounds) {
    _winningLineAnimationController.reset();
    final newGame = TicTacToeGameModel(maxRounds: maxRounds);
    onConfigUpdate(maxRounds, newGame);
  }

  void resetAll() {
    _winningLineAnimationController.reset();
    setState(() {
      game.resetAll();
    });
  }

  void onCellTap({required int rowIndex, required int columnIndex}) {
    if (game.makeMove(rowIndex, columnIndex)) {
      setState(() {});
      checkGameOver();
    }
  }

  void checkGameOver() {
    if (game.isGameOver) {
      if (game.winningLine != null) {
        _winningLineAnimationController.reset();
        _winningLineAnimationController.forward();
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        handleRoundEnd();
      });
    }
  }

  void handleRoundEnd() {
    game.updateScore();

    if (game.isAllRoundsFinished) {
      FinalScoreDialog.show(context, game, resetAll);
    } else {
      showRoundEndDialog();
    }
  }

  void showRoundEndDialog() {
    String message;
    if (game.winner != null) {
      message = 'Jogador ${game.winner?.value} venceu este round!';
    } else {
      message = 'Deu Velha';
    }

    setState(() {
      _roundEndMessage = message;
      _roundWinner = game.winner;
    });
  }

  void hideRoundEndMessage() {
    setState(() {
      _roundEndMessage = null;
      _roundWinner = null;
    });
  }

  void nextRound() {
    hideRoundEndMessage();
    _winningLineAnimationController.reset();
    setState(() {
      game.nextRound();
    });
  }

  @override
  void dispose() {
    _winningLineAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        onResetPressed: resetAll,
        currentMaxRounds: game.maxRounds,
        onMaxRoundsChanged: onMaxRoundsChanged,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CurrentPlayerIndicatorComponent(game: game),
                ScoreDisplayComponent(game: game),
                GameBoardComponent(
                  game: game,
                  winningLineAnimation: _winningLineAnimation,
                  onCellTap:
                      ({required int rowIndex, required int columnIndex}) =>
                          onCellTap(
                            rowIndex: rowIndex,
                            columnIndex: columnIndex,
                          ),
                ),
              ],
            ),
          ),
          if (_roundEndMessage != null)
            RoundEndBannerComponent(
              roundEndMessage: _roundEndMessage!,
              roundWinner: _roundWinner,
              onNextRound: nextRound,
            ),
        ],
      ),
    );
  }
}
