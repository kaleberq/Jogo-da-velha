import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onResetPressed;
  final int? currentMaxRounds;
  final Function(int)? onMaxRoundsChanged;
  final PlayerEnum currentPlayer;

  const AppBarComponent({
    super.key,
    this.onResetPressed,
    this.currentMaxRounds,
    this.onMaxRoundsChanged,
    required this.currentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Voltar',
      ),
      title: Text(
        'Vez do jogador: ${currentPlayer.value}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: currentPlayer == PlayerEnum.x ? Colors.blue : Colors.red,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showSettingsBottomSheet(context),
          tooltip: 'Configurações',
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    int tempMaxRounds = currentMaxRounds ?? 5;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configurações',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  // Opção de aumentar número de rounds
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Número de Rounds',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: tempMaxRounds > 1
                                ? () {
                                    setState(() {
                                      tempMaxRounds--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            '$tempMaxRounds',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: tempMaxRounds < 20
                                ? () {
                                    setState(() {
                                      tempMaxRounds++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha entre 1 e 20 rounds',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  // Botão para aplicar mudanças
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (onMaxRoundsChanged != null &&
                            tempMaxRounds != currentMaxRounds) {
                          onMaxRoundsChanged!(tempMaxRounds);
                        }
                        Navigator.of(bottomSheetContext).pop();
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Opção de reiniciar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        if (onResetPressed != null) {
                          onResetPressed!();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reiniciar Tudo'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
