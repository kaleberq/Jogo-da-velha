import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/final_score_bottom_sheet_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/score_display_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';

class LocalGameScreen extends StatefulWidget {
  final LocalGameViewModel viewModel;

  const LocalGameScreen({super.key, required this.viewModel});

  @override
  State<LocalGameScreen> createState() => _LocalGameScreenState();
}

class _LocalGameScreenState extends State<LocalGameScreen>
    with TickerProviderStateMixin {
  PlayerEnum? _roundWinner;
  late AnimationController _winningLineAnimationController;
  late Animation<double> _winningLineAnimation;

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
    widget.viewModel.setMaxRounds(maxRounds);
  }

  void resetAll() {
    _winningLineAnimationController.reset();
    widget.viewModel.resetAll();
  }

  void onCellTap({required int rowIndex, required int columnIndex}) {
    if (widget.viewModel.makeMove(rowIndex, columnIndex)) {
      checkGameOver();
    }
  }

  void checkGameOver() {
    if (widget.viewModel.game.isGameOver) {
      if (widget.viewModel.game.winningLine != null) {
        _winningLineAnimationController.reset();
        _winningLineAnimationController.forward();
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        handleRoundEnd();
      });
    }
  }

  void handleRoundEnd() {
    widget.viewModel.updateScore();

    if (widget.viewModel.isAllRoundsFinished) {
      _showFinalScoreBottomSheet();
    } else {
      showRoundEnd();
    }
  }

  void _showFinalScoreBottomSheet() {
    String winnerMessage;
    final PlayerEnum? overallWinner = widget.viewModel.overallWinner;
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
      widget: FinalScoreBottomSheetComponent(
        winnerMessage: winnerMessage,
        scoreX: widget.viewModel.game.scoreX,
        scoreO: widget.viewModel.game.scoreO,
        resetAll: () => resetAll(),
      ),
    );
  }

  void showRoundEnd() {
    String message;
    if (widget.viewModel.game.winner != null) {
      message = context.l10n.playerWonRound(
        widget.viewModel.game.winner!.value,
      );
    } else {
      message = context.l10n.drawRound;
    }

    setState(() {
      _roundWinner = widget.viewModel.game.winner;
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
          widget.viewModel.nextRound();

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
    widget.viewModel.nextRound();
  }

  @override
  void dispose() {
    _winningLineAnimationController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBarComponent(
            onResetPressed: resetAll,
            currentMaxRounds: widget.viewModel.game.maxRounds,
            onMaxRoundsChanged: onMaxRoundsChanged,
            currentPlayer: widget.viewModel.game.currentPlayer,
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
                ScoreDisplayComponent(game: widget.viewModel.game),
                GameBoardComponent(
                  game: widget.viewModel.game,
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
