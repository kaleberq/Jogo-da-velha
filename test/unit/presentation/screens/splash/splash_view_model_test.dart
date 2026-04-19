import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_data_source_channel_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_navigator_interface.dart';
import 'package:jogo_da_velha/presentation/screens/splash/models/splash_model.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_view_model.dart';

class FakeDeepLinkChannel implements IDeepLinkDataSourceChannel {
  Map<String, dynamic>? pendingRoute;

  @override
  Future<Map<String, dynamic>?> getPendingRoute() async => pendingRoute;
}

class FakeDeepLinkNavigator implements IDeepLinkNavigator {
  NavigatorState? navigator;
  Map<String, dynamic>? route;

  @override
  void navigate(NavigatorState navigator, Map<String, dynamic>? deepLink) {
    this.navigator = navigator;
    route = deepLink;
  }
}

void main() {
  group('SplashViewModel', () {
    test('startBoardAnimation flags animation as started', () {
      final vm = SplashViewModel(
        deeplinkDataSourceChannel: FakeDeepLinkChannel(),
        navigator: FakeDeepLinkNavigator(),
        ticTacToeGame: SplashModel(),
      );

      vm.startBoardAnimation();

      expect(vm.game.hasStartedBoardAnimation, isTrue);
    });

    testWidgets('navigate forwards deep link to navigator', (tester) async {
      final channel = FakeDeepLinkChannel()
        ..pendingRoute = {'route': '/menu'};
      final navigator = FakeDeepLinkNavigator();
      final vm = SplashViewModel(
        deeplinkDataSourceChannel: channel,
        navigator: navigator,
        ticTacToeGame: SplashModel(),
      );

      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => vm.navigate(context),
              child: const Text('go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(navigator.route?['route'], '/menu');
      expect(navigator.navigator, isNotNull);
    });
  });
}
