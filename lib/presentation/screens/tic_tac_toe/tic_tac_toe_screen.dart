import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/network/network_service.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/game_info_section_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/current_player_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_banner_component.dart';

class TicTacToeScreen extends StatefulWidget {
  final NetworkService? networkService;
  final bool isHost;

  const TicTacToeScreen({super.key, this.networkService, this.isHost = false});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with TickerProviderStateMixin {
  late TicTacToeGameModel game;
  String? _roundEndMessage;
  PlayerEnum? _roundWinner;
  int _maxRounds = 5;
  bool _isOnlineMode = false;
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

    _isOnlineMode = widget.networkService != null;

    // Em modo online, o host é sempre X e começa primeiro
    if (_isOnlineMode) {
      _isMyTurn = widget.isHost;
      game = TicTacToeGameModel(maxRounds: _maxRounds);
      if (widget.isHost) {
        game.currentPlayer = PlayerEnum.x;
      } else {
        game.currentPlayer = PlayerEnum.o;
        _isMyTurn = false;
      }

      // Configurar callbacks de rede
      widget.networkService!.onMessageReceived = _handleNetworkMessage;
      widget.networkService!.onConnectionStatusChanged = (status) {
        if (status == 'disconnected' && mounted) {
          Future.microtask(() {
            if (mounted) {
              _showDisconnectedDialog();
            }
          });
        }
      };
      widget.networkService!.onError = (error) {
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
    } else {
      game = TicTacToeGameModel(maxRounds: _maxRounds);
    }
  }

  void _handleNetworkMessage(String message) {
    if (message == 'DISCONNECTED') {
      if (mounted) {
        Future.microtask(() {
          if (mounted) {
            _showDisconnectedDialog();
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
            final row = data['row'] as int;
            final col = data['col'] as int;
            final playerStr = data['player'] as String;
            final player = playerStr == 'x' ? PlayerEnum.x : PlayerEnum.o;
            setState(() {
              game.makeMoveWithPlayer(row, col, player);
              _isMyTurn = true;
              _checkGameOver();
            });
            break;
          case 'reset':
            setState(() {
              game.resetAll();
              if (widget.isHost) {
                game.currentPlayer = PlayerEnum.x;
                _isMyTurn = true;
              } else {
                game.currentPlayer = PlayerEnum.o;
                _isMyTurn = false;
              }
            });
            break;
          case 'nextRound':
            setState(() {
              game.nextRound();
              if (widget.isHost) {
                game.currentPlayer = PlayerEnum.x;
                _isMyTurn = true;
              } else {
                game.currentPlayer = PlayerEnum.o;
                _isMyTurn = false;
              }
              _hideRoundEndMessage();
            });
            break;
          case 'config':
            final maxRounds = data['maxRounds'] as int;
            setState(() {
              _maxRounds = maxRounds;
              game = TicTacToeGameModel(maxRounds: _maxRounds);
              if (widget.isHost) {
                game.currentPlayer = PlayerEnum.x;
                _isMyTurn = true;
              } else {
                game.currentPlayer = PlayerEnum.o;
                _isMyTurn = false;
              }
            });
            break;
        }
      });
    } catch (e) {
      // Ignora mensagens que não são JSON válido
    }
  }

  void _showDisconnectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Conexão Perdida'),
        content: const Text('A conexão com o outro jogador foi perdida.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Voltar ao Menu'),
          ),
        ],
      ),
    );
  }

  void _onCellTap({required int rowIndex, required int columnIndex}) {
    // Em modo online, só permite jogar na vez do jogador
    if (_isOnlineMode && !_isMyTurn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aguarde sua vez!')));
      return;
    }

    // Em modo online, guarda o jogador atual ANTES de fazer o movimento
    final playerWhoMoved = _isOnlineMode ? game.currentPlayer : null;

    if (game.makeMove(rowIndex, columnIndex)) {
      // Em modo online, envia o movimento para o outro jogador
      if (_isOnlineMode && playerWhoMoved != null) {
        widget.networkService!.sendMove(
          rowIndex,
          columnIndex,
          playerWhoMoved.value,
        );
        _isMyTurn = false;
      }
      setState(() {});
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    if (game.isGameOver) {
      // Inicia a animação do traço se houver uma linha vencedora
      if (game.winningLine != null) {
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
    game.updateScore();

    // Verifica se chegou ao fim dos 5 rounds
    if (game.isAllRoundsFinished) {
      _showFinalScoreDialog();
    } else {
      _showRoundEndDialog();
    }
  }

  void _showRoundEndDialog() {
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

  void _hideRoundEndMessage() {
    setState(() {
      _roundEndMessage = null;
      _roundWinner = null;
    });
  }

  void _showFinalScoreDialog() {
    String winnerMessage;
    final PlayerEnum? overallWinner = game.overallWinner;
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
                'Jogador X: ${game.scoreX}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Jogador O: ${game.scoreO}',
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
                _resetAll();
              },
              child: const Text('Jogar Novamente'),
            ),
          ],
        );
      },
    );
  }

  void _nextRound() {
    _hideRoundEndMessage();
    _winningLineAnimationController.reset();
    if (_isOnlineMode) {
      widget.networkService!.sendNextRound();
    }
    setState(() {
      game.nextRound();
      if (_isOnlineMode) {
        // Em modo online, quem começa é baseado em quem é host
        if (widget.isHost) {
          game.currentPlayer = PlayerEnum.x;
          _isMyTurn = true;
        } else {
          game.currentPlayer = PlayerEnum.o;
          _isMyTurn = false;
        }
      }
    });
  }

  void _resetAll() {
    _winningLineAnimationController.reset();
    if (_isOnlineMode) {
      widget.networkService!.sendReset();
    }
    setState(() {
      game.resetAll();
      if (_isOnlineMode) {
        if (widget.isHost) {
          game.currentPlayer = PlayerEnum.x;
          _isMyTurn = true;
        } else {
          game.currentPlayer = PlayerEnum.o;
          _isMyTurn = false;
        }
      }
    });
  }

  void _showSettingsDialog() {
    int tempMaxRounds = _maxRounds;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurações'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Número de Rounds:'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: tempMaxRounds > 1
                            ? () {
                                setDialogState(() {
                                  tempMaxRounds--;
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$tempMaxRounds',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: tempMaxRounds < 20
                            ? () {
                                setDialogState(() {
                                  tempMaxRounds++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha entre 1 e 20 rounds',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    _winningLineAnimationController.reset();
                    setState(() {
                      _maxRounds = tempMaxRounds;
                      game = TicTacToeGameModel(maxRounds: _maxRounds);
                      if (_isOnlineMode) {
                        widget.networkService!.sendConfig(_maxRounds);
                        if (widget.isHost) {
                          game.currentPlayer = PlayerEnum.x;
                          _isMyTurn = true;
                        } else {
                          game.currentPlayer = PlayerEnum.o;
                          _isMyTurn = false;
                        }
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
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
        isOnlineMode: _isOnlineMode,
        isHost: widget.isHost,
        isMyTurn: _isMyTurn,
        networkService: widget.networkService,
        onSettingsPressed: _showSettingsDialog,
        onResetPressed: _resetAll,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameInfoSectionComponent(game: game),
                CurrentPlayerIndicatorComponent(game: game),
                GameBoardComponent(
                  game: game,
                  winningLineAnimation: _winningLineAnimation,
                  onCellTap:
                      ({required int rowIndex, required int columnIndex}) =>
                          _onCellTap(
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
              onNextRound: _nextRound,
            ),
        ],
      ),
    );
  }
}
