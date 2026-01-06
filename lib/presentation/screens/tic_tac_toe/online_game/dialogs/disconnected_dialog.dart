import 'package:flutter/material.dart';

class DisconnectedDialog {
  static void show(BuildContext context) {
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
}
