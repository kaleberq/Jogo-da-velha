import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/final_score_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/score_display_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/dialogs/disconnected_dialog.dart';

class OnlineGameScreen extends StatefulWidget {
  final OnlineGameViewModel viewModel;

  const OnlineGameScreen({super.key, required this.viewModel});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen>
    with TickerProviderStateMixin {
  PlayerEnum? _roundWinner;
  bool _isMyTurn = true;
  late AnimationController _winningLineAnimationController;
  late Animation<double> _winningLineAnimation;
  late final OnlineGameViewModel viewModel;

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

    _isMyTurn = viewModel.playerRole.isHost;
    _setupViewModelCallbacks();
  }

  void _setupViewModelCallbacks() {
    viewModel.onOpponentDisconnected = () {
      if (mounted) {
        DisconnectedDialog.show(context);
      }
    };
    viewModel.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    };
    viewModel.onMoveReceived = (row, col, player) {
      if (mounted) {
        viewModel.makeMoveWithPlayer(row, col, player);
        _isMyTurn = true;
        _checkGameOver();
      }
    };
    viewModel.onGameStateReceived = () {
      if (mounted) {
        _isMyTurn = viewModel.game.currentPlayer == viewModel.myPlayer;
        _checkGameOver();
        setState(() {});
      }
    };
    viewModel.onResetReceived = () {
      if (mounted) {
        viewModel.resetAll();
        _isMyTurn = viewModel.playerRole.isHost;
        setState(() {});
      }
    };
    viewModel.onNextRoundReceived = () {
      if (mounted) {
        Navigator.of(context).pop(); // fecha o modal no cliente

        viewModel.nextRound();
        _isMyTurn = viewModel.playerRole.isHost;
        _hideRoundEndMessage();

        setState(() {});
      }
    };
    viewModel.onConfigReceived = (maxRounds) {
      if (mounted) {
        viewModel.setMaxRounds(maxRounds);
        setState(() {
          _isMyTurn = viewModel.playerRole.isHost;
        });
      }
    };
  }

  void onCellTap({required int rowIndex, required int columnIndex}) {
    if (!_isMyTurn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.waitYourTurn)));
      return;
    }

    if (viewModel.playerRole.isHost) {
      // Host: aplica localmente e envia estado completo (autoridade).
      if (viewModel.makeMove(rowIndex, columnIndex)) {
        viewModel.sendCurrentGameState();
        _isMyTurn = false;
        _checkGameOver();
      }
    } else {
      // Cliente: envia apenas a jogada; host valida e envia estado.
      viewModel.sendRequestMove(rowIndex, columnIndex);
      _isMyTurn = false;
    }
  }

  void _checkGameOver() {
    if (viewModel.game.isGameOver) {
      if (viewModel.game.winningLine != null) {
        _winningLineAnimationController.reset();
        _winningLineAnimationController.forward();
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleRoundEnd();
      });
    }
  }

  void _handleRoundEnd() {
    viewModel.updateScore();

    if (viewModel.isAllRoundsFinished) {
      _showFinalScoreDialog();
    } else {
      _showRoundEnd();
    }
  }

  void _showFinalScoreDialog() {
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
        localPlayer: viewModel.myPlayer,
      ),
    );
  }

  void _showRoundEnd() {
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
        playerRole: viewModel.playerRole,
        onNextRound: () {
          _hideRoundEndMessage();
          _winningLineAnimationController.reset();
          viewModel.sendNextRound();
          viewModel.nextRound();
          _isMyTurn = viewModel.playerRole.isHost;

          Navigator.of(context).pop();
          setState(() {});
        },
      ),
    );
  }

  void _hideRoundEndMessage() {
    setState(() {
      _roundWinner = null;
    });
  }

  void resetAll() {
    _winningLineAnimationController.reset();
    viewModel.sendReset();
    viewModel.resetAll();
    _isMyTurn = viewModel.playerRole.isHost;
    setState(() {});
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
            playerRole: viewModel.playerRole,
            isMyTurn: _isMyTurn,
            onResetPressed: resetAll,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
            child: Column(
              spacing: DSSpacing.lg,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundIndicatorComponent(
                  currentRound: viewModel.game.currentRound,
                  totalRounds: viewModel.game.maxRounds,
                ),
                ScoreDisplayComponent(
                  scoreO: viewModel.game.scoreO,
                  scoreX: viewModel.game.scoreX,
                  currentPlayer: viewModel.game.currentPlayer,
                  localPlayer: viewModel.myPlayer,
                ),
                GameBoardComponent(
                  board: viewModel.game.board,
                  winningLine: viewModel.game.winningLine,
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
