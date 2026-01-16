import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: context.l10n.back,
      ),
      title: SvgPicture.asset(currentPlayer.assetPath, width: 24, height: 24),
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
              padding: EdgeInsets.all(DSSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.settings,
                    style: DSTypographySemiBold.labelLarge,
                  ),
                  SizedBox(height: DSSpacing.lg),
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
                  SizedBox(height: DSSpacing.sm),
                  Text(
                    context.l10n.chooseRoundsRange,
                    style: DSTypographyMedium.labelSmall,
                  ),
                  const SizedBox(height: DSSpacing.lg),
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
                  SizedBox(height: DSSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: DSColors.error(context)),
                      ),
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        if (onResetPressed != null) {
                          onResetPressed!();
                        }
                      },
                      icon: Icon(Icons.refresh, color: DSColors.error(context)),
                      label: Text(
                        context.l10n.resetAll,
                        style: DSTypographySemiBold.labelSmall.copyWith(
                          color: DSColors.error(context),
                        ),
                      ),
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
}
