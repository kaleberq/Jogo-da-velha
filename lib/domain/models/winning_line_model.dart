import 'package:jogo_da_velha/domain/enums/winning_line_enum.dart';

class WinningLineModel {
  final WinningLineEnum type;
  final int? index; // Para linhas horizontais e verticais (0, 1, 2)

  const WinningLineModel({required this.type, this.index});

  // Linha horizontal
  factory WinningLineModel.horizontal(int row) {
    return WinningLineModel(type: WinningLineEnum.horizontal, index: row);
  }

  // Linha vertical
  factory WinningLineModel.vertical(int col) {
    return WinningLineModel(type: WinningLineEnum.vertical, index: col);
  }

  // Diagonal principal (de cima-esquerda para baixo-direita)
  factory WinningLineModel.diagonalMain() {
    return const WinningLineModel(type: WinningLineEnum.diagonalMain);
  }

  // Diagonal secundária (de cima-direita para baixo-esquerda)
  factory WinningLineModel.diagonalSecondary() {
    return const WinningLineModel(type: WinningLineEnum.diagonalSecondary);
  }
}
