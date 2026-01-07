import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_banner_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/score_display_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';

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

  final LocalGameViewModel viewModel = LocalGameViewModel();

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

  void onMaxRoundsChanged(int maxRounds) {
    _winningLineAnimationController.reset();
    viewModel.setMaxRounds(maxRounds);
  }

  void resetAll() {
    _winningLineAnimationController.reset();
    viewModel.resetAll();
  }

  void onCellTap({required int rowIndex, required int columnIndex}) {
    if (viewModel.makeMove(rowIndex, columnIndex)) {
      checkGameOver();
    }
  }

  void checkGameOver() {
    if (viewModel.game.isGameOver) {
      if (viewModel.game.winningLine != null) {
        _winningLineAnimationController.reset();
        _winningLineAnimationController.forward();
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        handleRoundEnd();
      });
    }
  }

  void handleRoundEnd() {
    viewModel.updateScore();

    if (viewModel.isAllRoundsFinished) {
      // TODO: Atualizar FinalScoreDialog para aceitar TicTacToeGameModel ou criar método no viewModel
      // Por enquanto, vamos usar os dados do viewModel
      _showFinalScoreDialog();
    } else {
      showRoundEndDialog();
    }
  }

  void _showFinalScoreDialog() {
    String winnerMessage;
    final PlayerEnum? overallWinner = viewModel.overallWinner;
    if (overallWinner == PlayerEnum.x) {
      winnerMessage = 'Jogador X venceu o jogo!';
    } else if (overallWinner == PlayerEnum.o) {
      winnerMessage = 'Jogador O venceu o jogo!';
    } else {
      winnerMessage = 'Empate! Ninguém venceu.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fim do Jogo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                winnerMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Placar Final:',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'Jogador X: ${viewModel.game.scoreX}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Jogador O: ${viewModel.game.scoreO}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetAll();
              },
              child: const Text('Jogar Novamente'),
            ),
          ],
        );
      },
    );
  }

  void showRoundEndDialog() {
    String message;
    if (viewModel.game.winner != null) {
      message = 'Jogador ${viewModel.game.winner?.value} venceu este round!';
    } else {
      message = 'Deu Velha';
    }

    setState(() {
      _roundEndMessage = message;
      _roundWinner = viewModel.game.winner;
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
    viewModel.nextRound();
  }

  @override
  void dispose() {
    _winningLineAnimationController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBarComponent(
            onResetPressed: resetAll,
            currentMaxRounds: viewModel.game.maxRounds,
            onMaxRoundsChanged: onMaxRoundsChanged,
            currentPlayer: viewModel.game.currentPlayer,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ScoreDisplayComponent(game: viewModel.game),
                GameBoardComponent(
                  game: viewModel.game,
                  winningLineAnimation: _winningLineAnimation,
                  onCellTap:
                      ({required int rowIndex, required int columnIndex}) =>
                          onCellTap(
                            rowIndex: rowIndex,
                            columnIndex: columnIndex,
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
          ),
        );
      },
    );
  }
}
