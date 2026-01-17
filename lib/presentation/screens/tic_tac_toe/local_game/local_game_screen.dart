import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/final_score_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/score_display_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';

class LocalGameScreen extends StatefulWidget {
  final LocalGameViewModel viewModel;

  const LocalGameScreen({required this.viewModel, super.key});

  @override
  State<LocalGameScreen> createState() => _LocalGameScreenState();
}

class _LocalGameScreenState extends State<LocalGameScreen>
    with TickerProviderStateMixin {
  PlayerEnum? _roundWinner;
  late AnimationController _winningLineAnimationController;
  late Animation<double> _winningLineAnimation;
  late final LocalGameViewModel viewModel;

  @override
  void initState() {
    viewModel = widget.viewModel;

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
      _showFinalScoreBottomSheet();
    } else {
      showRoundEnd();
    }
  }

  void _showFinalScoreBottomSheet() {
    String winnerMessage;
    final PlayerEnum? overallWinner = viewModel.overallWinner;
    if (overallWinner == PlayerEnum.x) {
      winnerMessage = context.l10n.playerXWonGame;
    } else if (overallWinner == PlayerEnum.o) {
      winnerMessage = context.l10n.playerOWonGame;
    } else {
      winnerMessage = context.l10n.tieGame;
    }

    showDSModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      widget: FinalScoreComponent(
        winnerMessage: winnerMessage,
        scoreX: viewModel.game.scoreX,
        scoreO: viewModel.game.scoreO,
        resetAll: () => resetAll(),
      ),
    );
  }

  void showRoundEnd() {
    String message;
    if (viewModel.game.winner != null) {
      message = context.l10n.playerWonRound(viewModel.game.winner!.name);
    } else {
      message = context.l10n.drawRound;
    }

    setState(() {
      _roundWinner = viewModel.game.winner;
    });

    showDSModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      widget: RoundEnd(
        roundEndMessage: message,
        roundWinner: _roundWinner,
        onNextRound: () {
          _winningLineAnimationController.reset();
          viewModel.nextRound();

          Navigator.of(context).pop();
          setState(() {});
        },
      ),
    );
  }

  void hideRoundEndMessage() {
    setState(() {
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
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
            child: Column(
              spacing: DSSpacing.lg,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
