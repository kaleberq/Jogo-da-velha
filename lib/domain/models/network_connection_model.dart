import 'package:jogo_da_velha/domain/enums/connection_status_enum.dart';

class NetworkConnectionModel {
  ConnectionStatusEnum status;
  String? errorMessage;

  NetworkConnectionModel({
    this.status = ConnectionStatusEnum.disconnected,
    this.errorMessage,
  });
}
