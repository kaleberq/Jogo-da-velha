import 'package:flutter/material.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class DisconnectedDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.connectionLost),
        content: Text(context.l10n.connectionLostMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(context.l10n.backToMenu),
          ),
        ],
      ),
    );
  }
}
