import 'dart:io';

import 'package:test/test.dart';

import '../../lib/export/routed_context_exporter.dart';
import '../../lib/models/context_parcel.dart';
import '../../lib/routing/context_router.dart';

void main() {
  group('RoutedContextExporter', () {
    test('exports context by feature and module', () async {
      final parcels = [
        ContextParcel(summary: 'fa', mergeHistory: [0], feature: 'feat', module: 'modA'),
        ContextParcel(summary: 'fb', mergeHistory: [1], feature: 'feat'),
        ContextParcel(summary: 'ma', mergeHistory: [2], module: 'modB'),
        ContextParcel(summary: 'x', mergeHistory: [3]),
      ];
      final router = ContextRouter();
      final result = router.routeParcels(parcels);

      final temp = Directory.systemTemp.createTempSync('routed_export_test');
      final exporter = RoutedContextExporter(basePath: temp.path);
      await exporter.export(result);

      final featDir = Directory('${temp.path}/by_feature/feat');
      final modADir = Directory('${temp.path}/by_module/modA');
      final modBDir = Directory('${temp.path}/by_module/modB');
      expect(featDir.existsSync(), isTrue);
      expect(modADir.existsSync(), isTrue);
      expect(modBDir.existsSync(), isTrue);

      final featFile = File('${featDir.path}/context.md');
      final modAFile = File('${modADir.path}/context.md');
      expect(featFile.existsSync(), isTrue);
      expect(modAFile.existsSync(), isTrue);

      final featContent = featFile.readAsStringSync();
      expect(featContent.contains('fa'), isTrue);
      expect(featContent.contains('fb'), isTrue);
      expect(featContent.contains('x'), isFalse);
    });
  });
}
