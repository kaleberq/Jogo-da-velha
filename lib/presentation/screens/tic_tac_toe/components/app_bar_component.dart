import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/repositories/interfaces/game_repository_interface.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final bool isOnlineMode;
  final bool isHost;
  final bool isMyTurn;
  final IGameRepository? gameRepository;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onResetPressed;
  final VoidCallback? onExitPressed;
  final int? currentMaxRounds;
  final Function(int)? onMaxRoundsChanged;

  const AppBarComponent({
    super.key,
    required this.isOnlineMode,
    required this.isHost,
    required this.isMyTurn,
    this.gameRepository,
    this.onSettingsPressed,
    this.onResetPressed,
    this.onExitPressed,
    this.currentMaxRounds,
    this.onMaxRoundsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isOnlineMode ? Text(isHost ? 'Host (X)' : 'Convidado (O)') : null,
      leading: !isOnlineMode
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Voltar',
            )
          : null,
      actions: [
        if (isOnlineMode)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: isMyTurn
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Sua Vez',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Aguardando...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: isOnlineMode
              ? null
              : () => _showSettingsBottomSheet(context),
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
