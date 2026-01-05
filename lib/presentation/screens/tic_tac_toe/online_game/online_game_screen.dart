import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/repositories/interfaces/game_repository_interface.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/current_player_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_banner_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/dialogs/disconnected_dialog.dart';

class OnlineGameScreen extends StatefulWidget {
  final IGameRepository gameRepository;
  final bool isHost;

  const OnlineGameScreen({
    super.key,
    required this.gameRepository,
    required this.isHost,
  });

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen>
    with TickerProviderStateMixin {
  String? _roundEndMessage;
  PlayerEnum? _roundWinner;
  int _maxRounds = 5;
  bool _isMyTurn = true;
  late AnimationController _winningLineAnimationController;
  late Animation<double> _winningLineAnimation;

  late final OnlineGameViewModel viewModel = OnlineGameViewModel(
    isHost: widget.isHost,
    maxRounds: _maxRounds,
  );

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

    // Em modo online, o host é sempre X e começa primeiro
    _isMyTurn = widget.isHost;

    // Configurar callbacks de rede
    _setupNetworkCallbacks();
  }

  void _setupNetworkCallbacks() {
    widget.gameRepository.onMessageReceived = _handleNetworkMessage;
    widget.gameRepository.onConnectionStatusChanged = (status) {
      if (status == 'disconnected' && mounted) {
        Future.microtask(() {
          if (mounted) {
            DisconnectedDialog.show(context);
          }
        });
      }
    };
    widget.gameRepository.onError = (error) {
      if (mounted) {
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          }
        });
      }
    };
  }

  void _handleNetworkMessage(String message) {
    if (message == 'DISCONNECTED') {
      if (mounted) {
        Future.microtask(() {
          if (mounted) {
            DisconnectedDialog.show(context);
          }
        });
      }
      return;
    }

    // Ignora mensagens de handshake
    if (message == 'SERVER_CONNECTED' ||
        message == 'CLIENT_CONNECTED' ||
        message == 'CONNECTED') {
      return;
    }

    if (!mounted) return;

    try {
      final data = jsonDecode(message);
      final type = data['type'] as String;

      Future.microtask(() {
        if (!mounted) return;

        switch (type) {
          case 'move':
            _handleMoveMessage(data);
            break;
          case 'reset':
            _handleResetMessage();
            break;
          case 'nextRound':
            _handleNextRoundMessage();
            break;
          case 'config':
            _handleConfigMessage(data);
            break;
        }
      });
    } catch (e) {
      // Ignora mensagens que não são JSON válido
    }
  }

  void _handleMoveMessage(Map<String, dynamic> data) {
    final row = data['row'] as int;
    final col = data['col'] as int;
    final playerStr = data['player'] as String;
    final player = playerStr == 'x' ? PlayerEnum.x : PlayerEnum.o;

    viewModel.makeMoveWithPlayer(row, col, player);
    _isMyTurn = true;
    _checkGameOver();
  }

  void _handleResetMessage() {
    viewModel.resetAll();
    if (widget.isHost) {
      viewModel.game.currentPlayer = PlayerEnum.x;
      _isMyTurn = true;
    } else {
      viewModel.game.currentPlayer = PlayerEnum.o;
      _isMyTurn = false;
    }
    setState(() {});
  }

  void _handleNextRoundMessage() {
    viewModel.nextRound();
    if (widget.isHost) {
      viewModel.game.currentPlayer = PlayerEnum.x;
      _isMyTurn = true;
    } else {
      viewModel.game.currentPlayer = PlayerEnum.o;
      _isMyTurn = false;
    }
    _hideRoundEndMessage();
    setState(() {});
  }

  void _handleConfigMessage(Map<String, dynamic> data) {
    final maxRounds = data['maxRounds'] as int;
    viewModel.setMaxRounds(maxRounds);
    if (widget.isHost) {
      viewModel.game.currentPlayer = PlayerEnum.x;
    } else {
      viewModel.game.currentPlayer = PlayerEnum.o;
    }
    _maxRounds = maxRounds;
    setState(() {
      if (widget.isHost) {
        _isMyTurn = true;
      } else {
        _isMyTurn = false;
      }
    });
  }

  void onCellTap({required int rowIndex, required int columnIndex}) {
    // Em modo online, só permite jogar na vez do jogador
    if (!_isMyTurn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aguarde sua vez!')));
      return;
    }

    // Em modo online, guarda o jogador atual ANTES de fazer o movimento
    final playerWhoMoved = viewModel.game.currentPlayer;

    if (viewModel.makeMove(rowIndex, columnIndex)) {
      // Em modo online, envia o movimento para o outro jogador
      widget.gameRepository.sendMove(
        rowIndex,
        columnIndex,
        playerWhoMoved.value,
      );
      _isMyTurn = false;
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    if (viewModel.game.isGameOver) {
      // Inicia a animação do traço se houver uma linha vencedora
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
    // Atualiza pontuação
    viewModel.updateScore();

    // Verifica se chegou ao fim dos rounds
    if (viewModel.isAllRoundsFinished) {
      _showFinalScoreDialog();
    } else {
      _showRoundEndDialog();
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

  void _showRoundEndDialog() {
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

  void _hideRoundEndMessage() {
    setState(() {
      _roundEndMessage = null;
      _roundWinner = null;
    });
  }

  void nextRound() {
    _hideRoundEndMessage();
    _winningLineAnimationController.reset();
    widget.gameRepository.sendNextRound();
    viewModel.nextRound();
    // Em modo online, quem começa é baseado em quem é host
    if (widget.isHost) {
      viewModel.game.currentPlayer = PlayerEnum.x;
      _isMyTurn = true;
    } else {
      viewModel.game.currentPlayer = PlayerEnum.o;
      _isMyTurn = false;
    }
    setState(() {});
  }

  void resetAll() {
    _winningLineAnimationController.reset();
    widget.gameRepository.sendReset();
    viewModel.resetAll();
    if (widget.isHost) {
      viewModel.game.currentPlayer = PlayerEnum.x;
      _isMyTurn = true;
    } else {
      viewModel.game.currentPlayer = PlayerEnum.o;
      _isMyTurn = false;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _winningLineAnimationController.dispose();
    viewModel.dispose();
    widget.gameRepository.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBarComponent(
            isHost: widget.isHost,
            isMyTurn: _isMyTurn,
            onResetPressed: resetAll,
          ),
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CurrentPlayerIndicatorComponent(game: viewModel.game),
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
              if (_roundEndMessage != null)
                RoundEndBannerComponent(
                  roundEndMessage: _roundEndMessage!,
                  roundWinner: _roundWinner,
                  onNextRound: nextRound,
                ),
            ],
          ),
        );
      },
    );
  }
}
