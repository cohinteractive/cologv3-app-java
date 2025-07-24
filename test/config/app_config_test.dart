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

    test('toggle manual review mode', () {
      AppConfig.disableManualReview();
      expect(AppConfig.manualReview, isFalse);
      AppConfig.enableManualReview();
      expect(AppConfig.manualReview, isTrue);
    });
  });
}
