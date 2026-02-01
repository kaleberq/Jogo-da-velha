import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class LocalOptions extends StatefulWidget {
  const LocalOptions({super.key});

  @override
  State<LocalOptions> createState() => _LocalOptionsState();
}

const int _maxRounds = 5;
const int _timeLimitSeconds = 10;

int _tempMaxRounds = _maxRounds;
int _tempTimeLimitSeconds = _timeLimitSeconds;

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
                      onPressed: _tempMaxRounds > 1
                          ? () {
                              setState(() {
                                _tempMaxRounds--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$_tempMaxRounds',
                      style: DSTypographySemiBold.labelMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _tempMaxRounds < 20
                          ? () {
                              setState(() {
                                _tempMaxRounds++;
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
                      onPressed: _tempTimeLimitSeconds > 5
                          ? () {
                              setState(() {
                                _tempTimeLimitSeconds--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$_tempTimeLimitSeconds',
                      style: DSTypographySemiBold.labelMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _tempTimeLimitSeconds < 60
                          ? () {
                              setState(() {
                                _tempTimeLimitSeconds++;
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
                      maxRounds: _tempMaxRounds,
                      timeLimitSeconds: _tempTimeLimitSeconds,
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
