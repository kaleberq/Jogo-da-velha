import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/repositories/interfaces/game_repository_interface.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/game_info_section_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/current_player_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_banner_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/dialogs/settings_dialog.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/mixins/network_message_handler_mixin.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/mixins/game_actions_mixin.dart';

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
    with
        TickerProviderStateMixin,
        NetworkMessageHandlerMixin,
        GameActionsMixin {
  String? _roundEndMessage;
  PlayerEnum? _roundWinner;
  int _maxRounds = 5;
  bool _isMyTurn = true;
  late AnimationController _winningLineAnimationController;
  late Animation<double> _winningLineAnimation;

  @override
  late TicTacToeGameModel game;

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
    game = TicTacToeGameModel(maxRounds: _maxRounds);
    if (widget.isHost) {
      game.currentPlayer = PlayerEnum.x;
    } else {
      game.currentPlayer = PlayerEnum.o;
      _isMyTurn = false;
    }

    // Configurar callbacks de rede usando o mixin
    setupNetworkCallbacks();
  }

  // Implementação dos getters/setters do mixin
  @override
  bool get isOnlineMode => true;

  @override
  bool get isHost => widget.isHost;

  @override
  bool get isMyTurn => _isMyTurn;

  @override
  set isMyTurn(bool value) => _isMyTurn = value;

  @override
  IGameRepository? get gameRepository => widget.gameRepository;

  @override
  void onConfigUpdate(int maxRounds, TicTacToeGameModel newGame) {
    setState(() {
      _maxRounds = maxRounds;
      game = newGame;
      if (widget.isHost) {
        _isMyTurn = true;
      } else {
        _isMyTurn = false;
      }
    });
  }

  // Implementação dos getters/setters do GameActionsMixin
  @override
  AnimationController get winningLineAnimationController =>
      _winningLineAnimationController;

  @override
  String? get roundEndMessage => _roundEndMessage;

  @override
  set roundEndMessage(String? value) => _roundEndMessage = value;

  @override
  PlayerEnum? get roundWinner => _roundWinner;

  @override
  set roundWinner(PlayerEnum? value) => _roundWinner = value;

  @override
  void resetAll() {
    _winningLineAnimationController.reset();
    widget.gameRepository.sendReset();
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
  }

  void _showSettingsDialog() {
    SettingsDialog.show(
      context,
      currentMaxRounds: _maxRounds,
      isOnlineMode: true,
      isHost: widget.isHost,
      gameRepository: widget.gameRepository,
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
        isOnlineMode: true,
        isHost: widget.isHost,
        isMyTurn: _isMyTurn,
        gameRepository: widget.gameRepository,
        onSettingsPressed: _showSettingsDialog,
        onResetPressed: resetAll,
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
                          onCellTap(
                            rowIndex: rowIndex,
                            columnIndex: columnIndex,
                          ),
                ),
              ],
            ),
          ),
          if (roundEndMessage != null)
            RoundEndBannerComponent(
              roundEndMessage: roundEndMessage!,
              roundWinner: roundWinner,
              onNextRound: nextRound,
            ),
        ],
      ),
    );
  }
}
