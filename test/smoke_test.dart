import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';

void main() {
  group('Smoke tests', () {
    test('all routes must have non-empty path', () {
      for (final route in RoutesEnum.values) {
        expect(route.path, isNotEmpty);
      }
    });
  });
}
