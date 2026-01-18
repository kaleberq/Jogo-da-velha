import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class RoundIndicatorComponent extends StatelessWidget {
  final int currentRound;
  final int totalRounds;

  const RoundIndicatorComponent({
    super.key,
    required this.currentRound,
    required this.totalRounds,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${context.l10n.roundText} $currentRound / $totalRounds',
      style: DSTypographyMedium.labelLarge,
    );
  }
}
