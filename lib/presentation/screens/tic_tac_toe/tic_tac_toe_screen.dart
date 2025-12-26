import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/horizontal_divider_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/row_component.dart';
import 'package:jogo_da_velha/presentation/models/tic_tac_toe_game.dart';
import 'package:jogo_da_velha/services/network_service.dart';

class TicTacToeScreen extends StatefulWidget {
  final NetworkService? networkService;
  final bool isHost;

  const TicTacToeScreen({super.key, this.networkService, this.isHost = false});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  late TicTacToeGame game;
  String? _roundEndMessage;
  Player? _roundWinner;
  int _maxRounds = 5;
  bool _isOnlineMode = false;
  bool _isMyTurn = true;

  @override
  void initState() {
    super.initState();
    _isOnlineMode = widget.networkService != null;

    // Em modo online, o host é sempre X e começa primeiro
    if (_isOnlineMode) {
      _isMyTurn = widget.isHost;
      game = TicTacToeGame(maxRounds: _maxRounds);
      if (widget.isHost) {
        game.currentPlayer = Player.x;
      } else {
        game.currentPlayer = Player.o;
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
      game = TicTacToeGame(maxRounds: _maxRounds);
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
            final player = playerStr == 'x' ? Player.x : Player.o;
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
                game.currentPlayer = Player.x;
                _isMyTurn = true;
              } else {
                game.currentPlayer = Player.o;
                _isMyTurn = false;
              }
            });
            break;
          case 'nextRound':
            setState(() {
              game.nextRound();
              if (widget.isHost) {
                game.currentPlayer = Player.x;
                _isMyTurn = true;
              } else {
                game.currentPlayer = Player.o;
                _isMyTurn = false;
              }
              _hideRoundEndMessage();
            });
            break;
          case 'config':
            final maxRounds = data['maxRounds'] as int;
            setState(() {
              _maxRounds = maxRounds;
              game = TicTacToeGame(maxRounds: _maxRounds);
              if (widget.isHost) {
                game.currentPlayer = Player.x;
                _isMyTurn = true;
              } else {
                game.currentPlayer = Player.o;
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

  void _onCellTap(int row, int col) {
    // Em modo online, só permite jogar na vez do jogador
    if (_isOnlineMode && !_isMyTurn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aguarde sua vez!')));
      return;
    }

    // Em modo online, guarda o jogador atual ANTES de fazer o movimento
    final playerWhoMoved = _isOnlineMode ? game.currentPlayer : null;

    if (game.makeMove(row, col)) {
      // Em modo online, envia o movimento para o outro jogador
      if (_isOnlineMode && playerWhoMoved != null) {
        widget.networkService!.sendMove(
          row,
          col,
          playerWhoMoved == Player.x ? 'x' : 'o',
        );
        _isMyTurn = false;
      }
      setState(() {});
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    if (game.isGameOver) {
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
      message =
          'Jogador ${game.winner == Player.x ? 'X' : 'O'} venceu este round!';
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
    final Player? overallWinner = game.overallWinner;
    if (overallWinner == Player.x) {
      winnerMessage = 'Jogador X venceu o jogo!';
    } else if (overallWinner == Player.o) {
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
    if (_isOnlineMode) {
      widget.networkService!.sendNextRound();
    }
    setState(() {
      game.nextRound();
      if (_isOnlineMode) {
        // Em modo online, quem começa é baseado em quem é host
        if (widget.isHost) {
          game.currentPlayer = Player.x;
          _isMyTurn = true;
        } else {
          game.currentPlayer = Player.o;
          _isMyTurn = false;
        }
      }
    });
  }

  void _resetAll() {
    if (_isOnlineMode) {
      widget.networkService!.sendReset();
    }
    setState(() {
      game.resetAll();
      if (_isOnlineMode) {
        if (widget.isHost) {
          game.currentPlayer = Player.x;
          _isMyTurn = true;
        } else {
          game.currentPlayer = Player.o;
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
                    setState(() {
                      _maxRounds = tempMaxRounds;
                      game = TicTacToeGame(maxRounds: _maxRounds);
                      if (_isOnlineMode) {
                        widget.networkService!.sendConfig(_maxRounds);
                        if (widget.isHost) {
                          game.currentPlayer = Player.x;
                          _isMyTurn = true;
                        } else {
                          game.currentPlayer = Player.o;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isOnlineMode
            ? Text(widget.isHost ? 'Host (X)' : 'Convidado (O)')
            : null,
        actions: [
          if (_isOnlineMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: _isMyTurn
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Sua Vez',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Aguardando...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _isOnlineMode ? null : _showSettingsDialog,
            tooltip: 'Configurações',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isOnlineMode ? null : _resetAll,
            tooltip: 'Reiniciar Tudo',
          ),
          if (_isOnlineMode)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                widget.networkService?.disconnect();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              tooltip: 'Sair',
            ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Informações do jogo
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Text(
                        'Round ${game.currentRound}/${game.maxRounds}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'X: ${game.scoreX}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'O: ${game.scoreO}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Indicador de jogador atual
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: game.currentPlayer == Player.x
                        ? Colors.blue.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: game.currentPlayer == Player.x
                          ? Colors.blue
                          : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Vez do jogador: ${game.currentPlayer == Player.x ? 'X' : 'O'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: game.currentPlayer == Player.x
                          ? Colors.blue
                          : Colors.red,
                    ),
                  ),
                ),
                // Tabuleiro
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade800, width: 3),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        RowComponent(
                          rowIndex: 0,
                          row: game.board[0],
                          onCellTap: _onCellTap,
                        ),
                        const HorizontalDividerComponent(),
                        RowComponent(
                          rowIndex: 1,
                          row: game.board[1],
                          onCellTap: _onCellTap,
                        ),
                        const HorizontalDividerComponent(),
                        RowComponent(
                          rowIndex: 2,
                          row: game.board[2],
                          onCellTap: _onCellTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Banner no topo da tela
          if (_roundEndMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _roundWinner == Player.x
                      ? Colors.blue.shade700
                      : _roundWinner == Player.o
                      ? Colors.red.shade700
                      : Colors.grey.shade700,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _roundEndMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _nextRound();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Próximo Round'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
