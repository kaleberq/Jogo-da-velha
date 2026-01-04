import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/repositories/interfaces/game_repository_interface.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/components/app_bar_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/current_player_indicator_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/score_display_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/round_end_banner_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/mixins/game_actions_mixin.dart';

class LocalGameScreen extends StatefulWidget {
  const LocalGameScreen({super.key});

  @override
  State<LocalGameScreen> createState() => _LocalGameScreenState();
}

class _LocalGameScreenState extends State<LocalGameScreen>
    with TickerProviderStateMixin, GameActionsMixin {
  String? _roundEndMessage;
  PlayerEnum? _roundWinner;
  int _maxRounds = 5;
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

    game = TicTacToeGameModel(maxRounds: _maxRounds);
  }

  // Implementação dos getters/setters do mixin
  @override
  bool get isOnlineMode => false;

  @override
  bool get isMyTurn => true;

  @override
  set isMyTurn(bool value) {
    // No modo local, sempre é a vez do jogador
  }

  @override
  IGameRepository? get gameRepository => null;

  void onConfigUpdate(int maxRounds, TicTacToeGameModel newGame) {
    setState(() {
      _maxRounds = maxRounds;
      game = newGame;
    });
  }

  void onMaxRoundsChanged(int maxRounds) {
    _winningLineAnimationController.reset();
    final newGame = TicTacToeGameModel(maxRounds: maxRounds);
    onConfigUpdate(maxRounds, newGame);
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
    setState(() {
      game.resetAll();
    });
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
        onResetPressed: resetAll,
        currentMaxRounds: _maxRounds,
        onMaxRoundsChanged: onMaxRoundsChanged,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CurrentPlayerIndicatorComponent(game: game),
                ScoreDisplayComponent(game: game),
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
