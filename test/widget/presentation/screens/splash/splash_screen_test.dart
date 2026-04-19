import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_data_source_channel_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_navigator_interface.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';
import 'package:jogo_da_velha/presentation/screens/components/game_board_component.dart';
import 'package:jogo_da_velha/presentation/screens/splash/models/splash_model.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_screen.dart';
import 'package:jogo_da_velha/presentation/screens/splash/splash_view_model.dart';

class FakeDeepLinkChannel implements IDeepLinkDataSourceChannel {
  @override
  Future<Map<String, dynamic>?> getPendingRoute() async => null;
}

class FakeDeepLinkNavigator implements IDeepLinkNavigator {
  @override
  void navigate(NavigatorState navigator, Map<String, dynamic>? deepLink) {}
}

void main() {
  testWidgets('SplashScreen renders app title and board', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    final viewModel = SplashViewModel(
      deeplinkDataSourceChannel: FakeDeepLinkChannel(),
      navigator: FakeDeepLinkNavigator(),
      ticTacToeGame: SplashModel(),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(viewModel: viewModel),
      ),
    );
    await tester.pump();

    expect(find.byType(GameBoardComponent), findsOneWidget);
    expect(find.text('Jogo da Velha'), findsOneWidget);

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  });
}
