import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'dart:math';

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

    ///
    test('Test capitaliseChar', () {
      String smallC = 'c';
      String capitalC = 'C';
      String capitaliseCharResult = capitaliseChar(smallC);

      expect(capitaliseCharResult, capitalC);
    });
  });

  ///
  test('Test countVotes', () {
    Map<String, dynamic> map1 = {};
    map1['value'] = 1;

    Map<String, dynamic> map2 = {};
    map2['value'] = 3;

    int expectedCount = 4;

    List<Map<String, dynamic>> votesTest = [map1, map2];
    int count = countVotes(votesTest);

    expect(count, expectedCount);
  });

  ///
  test('Test getContainerWidth', () {
//       Test1
    double wi = 500;

    double containerWidth = getContainerWidth(width: wi);

    double expectedWidth = wi * 97.5 / 100;

    expect(containerWidth, expectedWidth);

//       Test 2
    wi = 650;

    containerWidth = getContainerWidth(width: wi);

    expectedWidth = min(wi * 95 / 100, 720);

    expect(containerWidth, expectedWidth);

//       Test 3
    wi = 800;

    containerWidth = getContainerWidth(width: wi);

    expectedWidth = min(wi * 90 / 100, 720);

    expect(containerWidth, expectedWidth);

//       Test 4
    wi = 1100;

    containerWidth = getContainerWidth(width: wi);

    expectedWidth = min(wi * 85 / 100, 720);

    expect(containerWidth, expectedWidth);

//       Test 5
    wi = 1450;

    containerWidth = getContainerWidth(width: wi);

    expectedWidth = min(wi * 80 / 100, 720);

    expect(containerWidth, expectedWidth);
  });
}
