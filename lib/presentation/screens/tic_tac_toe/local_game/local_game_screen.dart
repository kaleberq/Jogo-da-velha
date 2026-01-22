import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/final_score_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_indicator_component.dart';
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

  void _updateBorderAnimationController() {
    _borderAnimationController.dispose();
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
  }

  void onCellTap({required int rowIndex, required int columnIndex}) {
    if (viewModel.makeMove(rowIndex, columnIndex)) {
      checkGameOver();
    }
  }

  void checkGameOver() {
    if (viewModel.game.isGameOver) {
      // Para a animação da borda quando o round termina
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

  void _showSettingsBottomSheet() {
    int tempMaxRounds = viewModel.game.maxRounds;
    int tempTimeLimitSeconds = viewModel.game.timeLimitSeconds;

    _borderAnimationController.stop();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(DSSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.settings,
                    style: DSTypographySemiBold.labelLarge,
                  ),
                  SizedBox(height: DSSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.numberOfRounds,
                          style: DSTypographyMedium.labelMedium,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: tempMaxRounds > 1
                                ? () {
                                    setState(() {
                                      tempMaxRounds--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            '$tempMaxRounds',
                            style: DSTypographySemiBold.labelMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: tempMaxRounds < 20
                                ? () {
                                    setState(() {
                                      tempMaxRounds++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: DSSpacing.sm),
                  Text(
                    context.l10n.chooseRoundsRange,
                    style: DSTypographyMedium.labelSmall,
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.timeLimitSeconds,
                          style: DSTypographyMedium.labelMedium,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: tempTimeLimitSeconds > 5
                                ? () {
                                    setState(() {
                                      tempTimeLimitSeconds--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            '$tempTimeLimitSeconds',
                            style: DSTypographySemiBold.labelMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: tempTimeLimitSeconds < 60
                                ? () {
                                    setState(() {
                                      tempTimeLimitSeconds++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: DSSpacing.sm),
                  Text(
                    context.l10n.chooseTimeLimitRange,
                    style: DSTypographyMedium.labelSmall,
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (tempTimeLimitSeconds !=
                            viewModel.game.timeLimitSeconds) {
                          viewModel.setTimeLimitSeconds(tempTimeLimitSeconds);
                          _updateBorderAnimationController();
                        }

                        if (tempMaxRounds != viewModel.game.maxRounds) {
                          onMaxRoundsChanged(tempMaxRounds);
                        }

                        resetAll();
                        Navigator.of(bottomSheetContext).pop();
                      },
                      child: Text(
                        context.l10n.apply,
                        style: DSTypographySemiBold.labelMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: DSSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: DSColors.error(context)),
                      ),
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        resetAll();
                      },
                      icon: Icon(Icons.refresh, color: DSColors.error(context)),
                      label: Text(
                        context.l10n.resetAll,
                        style: DSTypographySemiBold.labelMedium.copyWith(
                          color: DSColors.error(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => _borderAnimationController.forward());
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
          appBar: AppBarComponent(
            onMaxRoundsChanged: onMaxRoundsChanged,
            showSettingsBottomSheet: () => _showSettingsBottomSheet(),
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
