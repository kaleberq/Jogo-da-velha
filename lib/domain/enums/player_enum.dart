import 'package:flutter/material.dart';
import 'package:jogo_da_velha/app/theme/app_colors.dart';

enum PlayerEnum {
  x(assetPath: 'assets/icons/x.svg', color: AppColors.playerX),
  o(assetPath: 'assets/icons/o.svg', color: AppColors.playerO),
  none(assetPath: '', color: Colors.transparent);

  final String assetPath;
  final Color color;

  const PlayerEnum({required this.assetPath, required this.color});
}
