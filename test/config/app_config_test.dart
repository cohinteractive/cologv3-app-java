import 'package:test/test.dart';
import '../../lib/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('toggle debug mode', () {
      AppConfig.disableDebug();
      expect(AppConfig.debugMode, isFalse);
      AppConfig.enableDebug();
      expect(AppConfig.debugMode, isTrue);
    });
  });
}
