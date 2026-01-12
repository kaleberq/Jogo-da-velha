import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

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
        tooltip: context.l10n.back,
      ),
      title: Text(
        context.l10n.playerTurn(currentPlayer.value),
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
          tooltip: context.l10n.settings,
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
                  Text(
                    context.l10n.settings,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Opção de aumentar número de rounds
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.numberOfRounds,
                          style: const TextStyle(fontSize: 16),
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
                    context.l10n.chooseRoundsRange,
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
                      child: Text(context.l10n.apply),
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
                      label: Text(context.l10n.resetAll),
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
