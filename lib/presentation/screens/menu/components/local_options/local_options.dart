import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class LocalOptions extends StatefulWidget {
  const LocalOptions({super.key});

  @override
  State<LocalOptions> createState() => _LocalOptionsState();
}

const int _maxRounds = 20;
const int _minRounds = 1;
const int _timeLimitMinSeconds = 10;
const int _timeLimitMaxSeconds = 60;

int _tempRounds = 5;
int _tempTimeSeconds = _timeLimitMinSeconds;

class _LocalOptionsState extends State<LocalOptions> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DSSpacing.md,
          horizontal: DSSpacing.lg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerRight,
              width: double.infinity,
              child: InkWell(
                borderRadius: BorderRadius.circular(DSRadius.md),
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 40),
              ),
            ),
            Text(context.l10n.settings, style: DSTypographySemiBold.labelLarge),
            SizedBox(height: DSSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.numberOfRounds,
                    style: DSTypographyMedium.labelMedium,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _tempRounds > _minRounds
                          ? () {
                              setState(() {
                                _tempRounds--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$_tempRounds',
                      style: DSTypographySemiBold.labelMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _tempRounds < _maxRounds
                          ? () {
                              setState(() {
                                _tempRounds++;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.timeLimitSeconds,
                    style: DSTypographyMedium.labelMedium,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _tempTimeSeconds > _timeLimitMinSeconds
                          ? () {
                              setState(() {
                                _tempTimeSeconds--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$_tempTimeSeconds',
                      style: DSTypographySemiBold.labelMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _tempTimeSeconds < _timeLimitMaxSeconds
                          ? () {
                              setState(() {
                                _tempTimeSeconds++;
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
              context.l10n.chooseTimeLimitRange,
              style: DSTypographyMedium.labelSmall,
            ),
            const SizedBox(height: DSSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    RoutesEnum.localGame.path,
                    arguments: (
                      maxRounds: _tempRounds,
                      timeLimitSeconds: _tempTimeSeconds,
                    ),
                  );
                },
                child: Text(
                  context.l10n.apply,
                  style: DSTypographySemiBold.labelMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
