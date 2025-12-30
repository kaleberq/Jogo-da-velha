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

  const AppBarComponent({
    super.key,
    required this.isOnlineMode,
    required this.isHost,
    required this.isMyTurn,
    this.gameRepository,
    this.onSettingsPressed,
    this.onResetPressed,
    this.onExitPressed,
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
          onPressed: isOnlineMode ? null : onSettingsPressed,
          tooltip: 'Configurações',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: isOnlineMode ? null : onResetPressed,
          tooltip: 'Reiniciar Tudo',
        ),
        if (isOnlineMode)
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              gameRepository?.disconnect();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            tooltip: 'Sair',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
