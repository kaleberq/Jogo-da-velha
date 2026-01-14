import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jogo_da_velha/main.dart' as app;
import 'package:jogo_da_velha/presentation/screens/menu/menu_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Test', () {
    testWidgets('navega para MenuScreen', (tester) async {
      app.main();

      await tester.pump();
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.byType(MenuScreen), findsOneWidget);
    });
  });
}
