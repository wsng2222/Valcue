import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/utils/reorder_utils.dart';

void main() {
  group('reorderItems', () {
    test('moves an item upward', () {
      final reordered = reorderItems(['a', 'b', 'c'], 2, 0);

      expect(reordered, ['c', 'a', 'b']);
    });

    test('moves an item downward using Flutter reorder semantics', () {
      final reordered = reorderItems(['a', 'b', 'c', 'd'], 0, 3);

      expect(reordered, ['b', 'c', 'a', 'd']);
    });

    test('supports moving an item to the end of the list', () {
      final reordered = reorderItems(['a', 'b', 'c'], 0, 3);

      expect(reordered, ['b', 'c', 'a']);
    });
  });
}
