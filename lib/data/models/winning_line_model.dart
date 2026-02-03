import 'package:jogo_da_velha/domain/enums/winning_line_enum.dart';

class WinningLineModel {
  final WinningLineEnum type;
  final int? index;

  const WinningLineModel({required this.type, this.index});

  factory WinningLineModel.horizontal(int row) {
    return WinningLineModel(type: WinningLineEnum.horizontal, index: row);
  }

  factory WinningLineModel.vertical(int col) {
    return WinningLineModel(type: WinningLineEnum.vertical, index: col);
  }

  factory WinningLineModel.diagonalMain() {
    return const WinningLineModel(type: WinningLineEnum.diagonalMain);
  }

  factory WinningLineModel.diagonalSecondary() {
    return const WinningLineModel(type: WinningLineEnum.diagonalSecondary);
  }
}
