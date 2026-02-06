import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';

class DeepLink {
  static const _channel = MethodChannel(
    'br.com.kalebemisael.jogodavelha/deeplink',
  );

  /// Busca a rota pendente no nativo (consumindo o valor).
  static Future<Map<String, dynamic>?> getPendingRoute() async {
    try {
      final result = await _channel.invokeMethod<Map>('getPendingRoute');
      return result?.cast<String, dynamic>();
    } on PlatformException {
      return null;
    }
  }

  /// Resolve o [deepLink] para [RoutesEnum]. Retorna [RoutesEnum.menu] se nulo ou inválido.
  static RoutesEnum resolveRoute(Map<String, dynamic>? deepLink) {
    final rawRoute = deepLink?['route'] as String?;
    if (rawRoute == null) return RoutesEnum.menu;

    final normalizedRoute = rawRoute.split('/').last.replaceAll('/', '');
    return RoutesEnum.values.firstWhere(
      (e) => e.path.replaceAll('/', '') == normalizedRoute,
      orElse: () => RoutesEnum.menu,
    );
  }

  /// Extrai argumentos do local game do [deepLink]. Aceita `timeLimit` ou `timeLimitSeconds`.
  static ({int maxRounds, int timeLimitSeconds}) getLocalGameArgs(
    Map<String, dynamic> deepLink,
  ) {
    final maxRounds = deepLink['maxRounds'] as int? ?? 10;
    final timeLimitSeconds =
        deepLink['timeLimitSeconds'] as int? ??
        deepLink['timeLimit'] as int? ??
        10;
    return (maxRounds: maxRounds, timeLimitSeconds: timeLimitSeconds);
  }

  /// Navega conforme o deep link: se [deepLink] for null, vai para o menu.
  /// Se rota for [RoutesEnum.localGame], empilha menu e depois local-game (voltar não sai do app).
  /// Caso contrário, substitui pela rota de destino.
  static void navigate(
    NavigatorState navigator,
    Map<String, dynamic>? deepLink,
  ) {
    final targetRoute = resolveRoute(deepLink);

    if (targetRoute == RoutesEnum.localGame && deepLink != null) {
      final args = getLocalGameArgs(deepLink);
      navigator.pushReplacementNamed(RoutesEnum.menu.path);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigator.pushNamed(
          RoutesEnum.localGame.path,
          arguments: (
            maxRounds: args.maxRounds,
            timeLimitSeconds: args.timeLimitSeconds,
          ),
        );
      });
    } else {
      navigator.pushReplacementNamed(targetRoute.path);
    }
  }
}
