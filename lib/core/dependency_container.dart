import 'package:jogo_da_velha/data/repositories/game_repository.dart';
import 'package:jogo_da_velha/data/services/network_service.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/services/network_service_interface.dart';

/// Container simples para gerenciar criação de dependências
/// Usa Constructor Injection puro: todas as dependências são injetadas via construtores
///
/// Este container é responsável por criar as instâncias concretas e injetá-las
/// nas classes que precisam delas. Em testes, você pode criar instâncias diretamente
/// passando mocks via construtores.
class DependencyContainer {
  // Instâncias singleton (quando necessário)
  static INetworkService? _networkService;
  static IGameRepository? _gameRepository;

  /// Cria ou retorna instância singleton de INetworkService
  static INetworkService getNetworkService() {
    _networkService ??= NetworkService();
    return _networkService!;
  }

  /// Cria ou retorna instância singleton de IGameRepository
  /// Usa Constructor Injection: injeta INetworkService no GameRepository
  static IGameRepository getGameRepository() {
    if (_gameRepository == null) {
      final networkService = getNetworkService();
      _gameRepository = GameRepository(networkService: networkService);
    }
    return _gameRepository!;
  }

  /// Reseta todas as dependências (útil para testes)
  static void reset() {
    _networkService = null;
    _gameRepository = null;
  }
}
