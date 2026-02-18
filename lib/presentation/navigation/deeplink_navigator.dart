import 'package:flutter/widgets.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_navigator_interface.dart';

class DeepLinkNavigator implements IDeepLinkNavigator {
  RoutesEnum _resolveRoute(Map<String, dynamic>? deepLink) {
    final rawRoute = deepLink?['route'] as String?;
    if (rawRoute == null) return RoutesEnum.menu;

    final normalizedRoute = rawRoute.split('/').last.replaceAll('/', '');
    return RoutesEnum.values.firstWhere(
      (e) => e.path.replaceAll('/', '') == normalizedRoute,
      orElse: () => RoutesEnum.menu,
    );
  }

  @override
  void navigate(NavigatorState navigator, Map<String, dynamic>? deepLink) {
    final targetRoute = _resolveRoute(deepLink);

    if (targetRoute == RoutesEnum.localGame && deepLink != null) {
      final maxRounds = deepLink['maxRounds'] as int? ?? 10;
      final timeLimitSeconds = deepLink['timeLimitSeconds'] as int? ?? 10;

      navigator.pushReplacementNamed(RoutesEnum.menu.path);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigator.pushNamed(
          RoutesEnum.localGame.path,
          arguments: (maxRounds: maxRounds, timeLimitSeconds: timeLimitSeconds),
        );
      });
    } else {
      navigator.pushReplacementNamed(targetRoute.path);
    }
  }
}
