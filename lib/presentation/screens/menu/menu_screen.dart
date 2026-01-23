import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/core/dependency_container.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/online_options/online_options.dart';
import 'package:jogo_da_velha/presentation/screens/online_options/online_options_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.menuTitle,
          style: DSTypographySemiBold.labelLarge,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DSSpacing.md,
              horizontal: DSSpacing.lg,
            ),
            child: Column(
              spacing: DSSpacing.md,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.chooseGameMode,
                  style: DSTypographyMedium.labelLarge,
                  textAlign: TextAlign.center,
                ),
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              LocalGameScreen(viewModel: LocalGameViewModel()),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      child: Row(
                        spacing: DSSpacing.md,
                        children: [
                          Icon(Icons.phone_android, size: 48),
                          Expanded(
                            child: Column(
                              spacing: DSSpacing.xs,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.localModeTitle,
                                  style: DSTypographyMedium.labelLarge,
                                ),
                                Text(
                                  context.l10n.localModeDescription,
                                  style: DSTypographyRegular.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () {
                      showDSModalBottomSheet(
                        context: context,
                        widget: OnlineOptions(
                          viewModel: OnlineOptionsViewModel(
                            gameRepository:
                                DependencyContainer.getGameRepository(),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      child: Row(
                        spacing: DSSpacing.md,
                        children: [
                          Icon(Icons.wifi, size: 48),
                          Expanded(
                            child: Column(
                              spacing: DSSpacing.xs,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.onlineModeTitle,
                                  style: DSTypographyMedium.labelLarge,
                                ),
                                Text(
                                  context.l10n.onlineModeDescription,
                                  style: DSTypographyRegular.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
