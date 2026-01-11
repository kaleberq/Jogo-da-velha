import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_bottom_sheet_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/components/score_display_component.dart';
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

    _isMyTurn = widget.viewModel.isHost;
    _setupViewModelCallbacks();
  }

  void _setupViewModelCallbacks() {
    widget.viewModel.onOpponentDisconnected = () {
      if (mounted) {
        DisconnectedDialog.show(context);
      }
    };
    widget.viewModel.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    };
    widget.viewModel.onMoveReceived = (row, col, player) {
      if (mounted) {
        widget.viewModel.makeMoveWithPlayer(row, col, player);
        _isMyTurn = true;
        _checkGameOver();
      }
    };
    widget.viewModel.onResetReceived = () {
      if (mounted) {
        widget.viewModel.resetAll();
        _isMyTurn = widget.viewModel.isHost;
        setState(() {});
      }
    };
    widget.viewModel.onNextRoundReceived = () {
      if (mounted) {
        widget.viewModel.nextRound();
        _isMyTurn = widget.viewModel.isHost;
        _hideRoundEndMessage();
        setState(() {});
      }
    };
    widget.viewModel.onConfigReceived = (maxRounds) {
      if (mounted) {
        widget.viewModel.setMaxRounds(maxRounds);
        setState(() {
          _isMyTurn = widget.viewModel.isHost;
        });
      }
    };
  }

  void onCellTap({required int rowIndex, required int columnIndex}) {
    if (!_isMyTurn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aguarde sua vez!')));
      return;
    }

    final playerWhoMoved = widget.viewModel.game.currentPlayer;
    if (widget.viewModel.makeMove(rowIndex, columnIndex)) {
      widget.viewModel.sendMove(rowIndex, columnIndex, playerWhoMoved);
      _isMyTurn = false;
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    if (widget.viewModel.game.isGameOver) {
      if (widget.viewModel.game.winningLine != null) {
        _winningLineAnimationController.reset();
        _winningLineAnimationController.forward();
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleRoundEnd();
      });
    }
  }

  void _handleRoundEnd() {
    widget.viewModel.updateScore();

    if (widget.viewModel.isAllRoundsFinished) {
      _showFinalScoreDialog();
    } else {
      _showRoundEnd();
    }
  }

  void _showFinalScoreDialog() {
    String winnerMessage;
    final PlayerEnum? overallWinner = widget.viewModel.overallWinner;
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
                'Jogador X: ${widget.viewModel.game.scoreX}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Jogador O: ${widget.viewModel.game.scoreO}',
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

  void _showRoundEnd() {
    String message;
    if (widget.viewModel.game.winner != null) {
      message =
          'Jogador ${widget.viewModel.game.winner?.value} venceu este round!';
    } else {
      message = 'Deu Velha';
    }

    setState(() {
      _roundWinner = widget.viewModel.game.winner;
    });

    showDSModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      widget: RoundEndBottomSheet(
        roundEndMessage: message,
        roundWinner: _roundWinner,
        onNextRound: () {
          _hideRoundEndMessage();
          _winningLineAnimationController.reset();
          widget.viewModel.sendNextRound();
          widget.viewModel.nextRound();
          _isMyTurn = widget.viewModel.isHost;

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
    widget.viewModel.sendReset();
    widget.viewModel.resetAll();
    _isMyTurn = widget.viewModel.isHost;
    setState(() {});
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
            isHost: widget.viewModel.isHost,
            isMyTurn: _isMyTurn,
            onResetPressed: resetAll,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.center,
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
