import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/network/network_service.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/dialogs/disconnected_dialog.dart';

mixin NetworkMessageHandlerMixin<T extends StatefulWidget> on State<T> {
  // Propriedades que devem ser fornecidas pela classe que usa o mixin
  TicTacToeGameModel get game;
  bool get isOnlineMode;
  bool get isHost;
  bool get isMyTurn;
  NetworkService? get networkService;

  // Setters para atualizar estado
  set isMyTurn(bool value);

  // Métodos que devem ser implementados pela classe
  void checkGameOver();
  void hideRoundEndMessage();

  // Callback para atualizar configurações
  void onConfigUpdate(int maxRounds, TicTacToeGameModel newGame);

  void setupNetworkCallbacks() {
    if (networkService == null) return;

    networkService!.onMessageReceived = handleNetworkMessage;
    networkService!.onConnectionStatusChanged = (status) {
      if (status == 'disconnected' && mounted) {
        Future.microtask(() {
          if (mounted) {
            DisconnectedDialog.show(context);
          }
        });
      }
    };
    networkService!.onError = (error) {
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

  void handleNetworkMessage(String message) {
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
            handleMoveMessage(data);
            break;
          case 'reset':
            handleResetMessage();
            break;
          case 'nextRound':
            handleNextRoundMessage();
            break;
          case 'config':
            handleConfigMessage(data);
            break;
        }
      });
    } catch (e) {
      // Ignora mensagens que não são JSON válido
    }
  }

  void handleMoveMessage(Map<String, dynamic> data) {
    final row = data['row'] as int;
    final col = data['col'] as int;
    final playerStr = data['player'] as String;
    final player = playerStr == 'x' ? PlayerEnum.x : PlayerEnum.o;

    setState(() {
      game.makeMoveWithPlayer(row, col, player);
      isMyTurn = true;
      checkGameOver();
    });
  }

  void handleResetMessage() {
    setState(() {
      game.resetAll();
      if (isHost) {
        game.currentPlayer = PlayerEnum.x;
        isMyTurn = true;
      } else {
        game.currentPlayer = PlayerEnum.o;
        isMyTurn = false;
      }
    });
  }

  void handleNextRoundMessage() {
    setState(() {
      game.nextRound();
      if (isHost) {
        game.currentPlayer = PlayerEnum.x;
        isMyTurn = true;
      } else {
        game.currentPlayer = PlayerEnum.o;
        isMyTurn = false;
      }
      hideRoundEndMessage();
    });
  }

  void handleConfigMessage(Map<String, dynamic> data) {
    final maxRounds = data['maxRounds'] as int;
    final newGame = TicTacToeGameModel(maxRounds: maxRounds);

    if (isHost) {
      newGame.currentPlayer = PlayerEnum.x;
    } else {
      newGame.currentPlayer = PlayerEnum.o;
    }

    onConfigUpdate(maxRounds, newGame);
  }
}
