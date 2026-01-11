import 'package:flutter/material.dart';

class FinalScoreBottomSheetComponent extends StatelessWidget {
  final String winnerMessage;
  final int scoreX;
  final int scoreO;
  final Function() resetAll;

  const FinalScoreBottomSheetComponent({
    required this.winnerMessage,
    required this.scoreX,
    required this.scoreO,
    required this.resetAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text('Fim do Jogo'),
          Column(
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
                'Jogador X: $scoreX',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Jogador O: $scoreO',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetAll();
            },
            child: const Text('Jogar Novamente'),
          ),
        ],
      ),
    );
  }
}
