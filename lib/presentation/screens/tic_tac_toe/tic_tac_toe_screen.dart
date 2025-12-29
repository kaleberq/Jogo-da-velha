import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/network/network_service.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/game_info_section_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/current_player_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_banner_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/dialogs/final_score_dialog.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/dialogs/settings_dialog.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/mixins/network_message_handler_mixin.dart';

class TicTacToeScreen extends StatefulWidget {
  final NetworkService? networkService;
  final bool isHost;

  const TicTacToeScreen({super.key, this.networkService, this.isHost = false});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with TickerProviderStateMixin, NetworkMessageHandlerMixin {
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

      // Configurar callbacks de rede usando o mixin
      setupNetworkCallbacks();
    } else {
      game = TicTacToeGameModel(maxRounds: _maxRounds);
    }
  }

  // Implementação dos getters/setters do mixin
  @override
  bool get isOnlineMode => _isOnlineMode;

  @override
  bool get isHost => widget.isHost;

  @override
  bool get isMyTurn => _isMyTurn;

  @override
  set isMyTurn(bool value) => _isMyTurn = value;

  @override
  NetworkService? get networkService => widget.networkService;

  @override
  void checkGameOver() => _checkGameOver();

  @override
  void hideRoundEndMessage() => _hideRoundEndMessage();

  @override
  void onConfigUpdate(int maxRounds, TicTacToeGameModel newGame) {
    setState(() {
      _maxRounds = maxRounds;
      game = newGame;
      if (_isOnlineMode) {
        if (widget.isHost) {
          _isMyTurn = true;
        } else {
          _isMyTurn = false;
        }
      }
    });
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
      FinalScoreDialog.show(context, game, _resetAll);
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
    SettingsDialog.show(
      context,
      currentMaxRounds: _maxRounds,
      isOnlineMode: _isOnlineMode,
      isHost: widget.isHost,
      networkService: widget.networkService,
      winningLineAnimationController: _winningLineAnimationController,
      onSave: onConfigUpdate,
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
