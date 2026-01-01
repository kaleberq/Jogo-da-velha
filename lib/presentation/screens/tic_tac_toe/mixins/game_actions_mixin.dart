import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/repositories/interfaces/game_repository_interface.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/dialogs/final_score_dialog.dart';

mixin GameActionsMixin<T extends StatefulWidget> on State<T> {
  // Propriedades que devem ser fornecidas pela classe que usa o mixin
  TicTacToeGameModel get game;
  bool get isOnlineMode;
  bool get isMyTurn;
  bool get isHost => false;
  IGameRepository? get gameRepository;
  AnimationController get winningLineAnimationController;
  String? get roundEndMessage;
  PlayerEnum? get roundWinner;

  // Setters para atualizar estado
  set isMyTurn(bool value);
  set roundEndMessage(String? value);
  set roundWinner(PlayerEnum? value);

  // Métodos que devem ser implementados pela classe
  void resetAll();

  void onCellTap({required int rowIndex, required int columnIndex}) {
    // Em modo online, só permite jogar na vez do jogador
    if (isOnlineMode && !isMyTurn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aguarde sua vez!')));
      return;
    }

    // Em modo online, guarda o jogador atual ANTES de fazer o movimento
    final playerWhoMoved = isOnlineMode ? game.currentPlayer : null;

    if (game.makeMove(rowIndex, columnIndex)) {
      // Em modo online, envia o movimento para o outro jogador
      if (isOnlineMode && playerWhoMoved != null) {
        gameRepository!.sendMove(rowIndex, columnIndex, playerWhoMoved.value);
        isMyTurn = false;
      }
      setState(() {});
      checkGameOver();
    }
  }

  void checkGameOver() {
    if (game.isGameOver) {
      // Inicia a animação do traço se houver uma linha vencedora
      if (game.winningLine != null) {
        winningLineAnimationController.reset();
        winningLineAnimationController.forward();
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        handleRoundEnd();
      });
    }
  }

  void handleRoundEnd() {
    // Atualiza pontuação
    game.updateScore();

    // Verifica se chegou ao fim dos rounds
    if (game.isAllRoundsFinished) {
      FinalScoreDialog.show(context, game, resetAll);
    } else {
      showRoundEndDialog();
    }
  }

  void showRoundEndDialog() {
    String message;
    if (game.winner != null) {
      message = 'Jogador ${game.winner?.value} venceu este round!';
    } else {
      message = 'Deu Velha';
    }

    setState(() {
      roundEndMessage = message;
      roundWinner = game.winner;
    });
  }

  void hideRoundEndMessage() {
    setState(() {
      roundEndMessage = null;
      roundWinner = null;
    });
  }

  void nextRound() {
    hideRoundEndMessage();
    winningLineAnimationController.reset();
    if (isOnlineMode) {
      gameRepository!.sendNextRound();
    }
    setState(() {
      game.nextRound();
      if (isOnlineMode) {
        // Em modo online, quem começa é baseado em quem é host
        if (isHost) {
          game.currentPlayer = PlayerEnum.x;
          isMyTurn = true;
        } else {
          game.currentPlayer = PlayerEnum.o;
          isMyTurn = false;
        }
      }
    });
  }
}
