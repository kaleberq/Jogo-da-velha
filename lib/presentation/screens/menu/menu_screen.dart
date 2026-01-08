import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/online_options/online_options_screen.dart';

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
          'Escolha um modo de jogo',
          style: DSTypographySemiBold.labelLarge.copyWith(
            color: DSColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: DSSpacing.md,
            horizontal: DSSpacing.lg,
          ),
          child: Column(
            spacing: DSSpacing.lg,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LocalGameScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(DSSpacing.lg),
                    child: Row(
                      spacing: DSSpacing.md,
                      children: [
                        const Icon(
                          Icons.phone_android,
                          size: 48,
                          color: DSColors.primary,
                        ),
                        Expanded(
                          child: Column(
                            spacing: DSSpacing.xs,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo Local',
                                style: DSTypographySemiBold.labelLarge.copyWith(
                                  color: DSColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Jogue no mesmo dispositivo',
                                style: DSTypographyMedium.labelSmall.copyWith(
                                  color: DSColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: DSColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OnlineOptionsScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(DSSpacing.lg),
                    child: Row(
                      spacing: DSSpacing.md,
                      children: [
                        const Icon(
                          Icons.wifi,
                          size: 48,
                          color: DSColors.primary,
                        ),
                        Expanded(
                          child: Column(
                            spacing: DSSpacing.xs,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jogar Online',
                                style: DSTypographySemiBold.labelLarge.copyWith(
                                  color: DSColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Jogue com outro jogador online',
                                style: DSTypographyMedium.labelSmall.copyWith(
                                  color: DSColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: DSColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
