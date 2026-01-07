import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';

class RoundEndBannerComponent extends StatelessWidget {
  final String roundEndMessage;
  final PlayerEnum? roundWinner;
  final VoidCallback onNextRound;

  const RoundEndBannerComponent({
    super.key,
    required this.roundEndMessage,
    required this.roundWinner,
    required this.onNextRound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: roundWinner == PlayerEnum.x
            ? Colors.blue.shade700
            : roundWinner == PlayerEnum.o
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              roundEndMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: onNextRound,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Próximo Round'),
          ),
        ],
      ),
    );
  }
}
