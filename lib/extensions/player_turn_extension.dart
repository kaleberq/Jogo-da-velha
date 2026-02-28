import 'package:jogo_da_velha/domain/enums/player_enum.dart';

extension PlayerTurn on PlayerEnum {
  PlayerEnum get next => this == PlayerEnum.x ? PlayerEnum.o : PlayerEnum.x;
}
