import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/final_score_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_indicator_component.dart';
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
  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;
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

    _borderAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: viewModel.game.timeLimitSeconds),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderAnimationController, curve: Curves.linear),
    );

    _borderAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!viewModel.game.isGameOver) {
          viewModel.endGameByTimeLimit();
          checkGameOver();
        }
      }
    });
    _borderAnimationController.forward();
  }

  void onMaxRoundsChanged(int maxRounds) {
    _winningLineAnimationController.reset();
    viewModel.setMaxRounds(maxRounds);
  }

  void resetAll() {
    _winningLineAnimationController.reset();
    _borderAnimationController.reset();
    _borderAnimationController.forward();
    viewModel.resetAll();
  }

  void onCellTap({required int rowIndex, required int columnIndex}) {
    if (viewModel.makeMove(rowIndex, columnIndex)) {
      checkGameOver();
    }
  }

  void checkGameOver() {
    if (viewModel.game.isGameOver) {
      _borderAnimationController.stop();

      if (viewModel.game.winningLine != null) {
        _winningLineAnimationController.reset();
        _winningLineAnimationController.forward();
      }

      handleRoundEnd();
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
    final PlayerEnum? winner = viewModel.game.winner;
    if (winner != null) {
      message = context.l10n.playerWonRound(winner.name);
    } else {
      message = context.l10n.drawRound;
    }

    setState(() {
      _roundWinner = winner;
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
          _borderAnimationController.reset();

          viewModel.nextRound();
          _borderAnimationController.forward();

          Navigator.of(context).pop();
        },
      ),
    );
  }

  void hideRoundEndMessage() {
    setState(() {
      _roundWinner = null;
    });
  }

  @override
  void dispose() {
    _winningLineAnimationController.dispose();
    _borderAnimationController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(),
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
                RoundIndicatorComponent(
                  currentRound: viewModel.game.currentRound,
                  totalRounds: viewModel.game.maxRounds,
                ),
                ScoreDisplayComponent(game: viewModel.game),
                GameBoardComponent(
                  game: viewModel.game,
                  winningLineAnimation: _winningLineAnimation,
                  borderAnimation: _borderAnimation,
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
