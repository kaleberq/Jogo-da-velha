enum WinningLineType { horizontal, vertical, diagonalMain, diagonalSecondary }

class WinningLine {
  final WinningLineType type;
  final int? index; // Para linhas horizontais e verticais (0, 1, 2)

  const WinningLine({required this.type, this.index});

  // Linha horizontal
  factory WinningLine.horizontal(int row) {
    return WinningLine(type: WinningLineType.horizontal, index: row);
  }

  // Linha vertical
  factory WinningLine.vertical(int col) {
    return WinningLine(type: WinningLineType.vertical, index: col);
  }

  // Diagonal principal (de cima-esquerda para baixo-direita)
  factory WinningLine.diagonalMain() {
    return const WinningLine(type: WinningLineType.diagonalMain);
  }

  // Diagonal secundária (de cima-direita para baixo-esquerda)
  factory WinningLine.diagonalSecondary() {
    return const WinningLine(type: WinningLineType.diagonalSecondary);
  }
}
