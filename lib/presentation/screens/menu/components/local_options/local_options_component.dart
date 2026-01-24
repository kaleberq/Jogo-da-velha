import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';

class LocalOptionsComponent extends StatefulWidget {
  const LocalOptionsComponent({super.key});

  @override
  State<LocalOptionsComponent> createState() => _LocalOptionsComponentState();
}

const int maxRounds = 5;
const int timeLimitSeconds = 10;

int tempMaxRounds = maxRounds;
int tempTimeLimitSeconds = timeLimitSeconds;

class _LocalOptionsComponentState extends State<LocalOptionsComponent> {
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
                      style: DSTypographySemiBold.labelMedium,
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
                      icon: const Icon(Icons.remove),
                      onPressed: tempTimeLimitSeconds > 5
                          ? () {
                              setState(() {
                                tempTimeLimitSeconds--;
                              });
                            }
                          : null,
                    ),
                    Text(
                      '$tempTimeLimitSeconds',
                      style: DSTypographySemiBold.labelMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: tempTimeLimitSeconds < 60
                          ? () {
                              setState(() {
                                tempTimeLimitSeconds++;
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LocalGameScreen(
                        viewModel: LocalGameViewModel(
                          maxRounds: tempMaxRounds,
                          timeLimitSeconds: tempTimeLimitSeconds,
                        ),
                      ),
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
