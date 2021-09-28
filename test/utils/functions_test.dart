import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/utils/functions.dart';

void main() {
  /// test witsOverflow/utils/functions.dart
  group('Testing functions', () {
    ///
    test('Test toTitleCase', () {
      String line = 'test to title case';
      String titleLine = 'Test To Title Case';
      String toTitleCaseResult = toTitleCase(line);

      expect(toTitleCaseResult, titleLine);
    });

    ///
    test('Test formatDateTime', () {
      DateTime datetime = DateTime(2021, 8, 1, 2, 3, 4);

      String formatDatetime = formatDateTime(datetime);

      expect(formatDatetime.contains('21'), true);
      expect(formatDatetime.contains('Aug'), true);
      expect(formatDatetime.contains('1'), true);
    });
  });
}
