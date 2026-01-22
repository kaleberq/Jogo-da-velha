import 'package:flutter/material.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final Function() showSettingsBottomSheet;
  final Function(int)? onMaxRoundsChanged;

  const AppBarComponent({
    super.key,

    this.onMaxRoundsChanged,
    required this.showSettingsBottomSheet,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: context.l10n.back,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => showSettingsBottomSheet(),
          tooltip: context.l10n.settings,
        ),
      ],
    );
  }
}
