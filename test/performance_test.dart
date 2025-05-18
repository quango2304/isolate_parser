import 'dart:convert';
import 'package:isolate_parser/isolate_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_models.dart';

void main() {
  late IsolateParserInterface isolate;
  
  setUp(() {
    isolate = IsolateParser();
    isolate.init();
  });

  tearDown(() {
    isolate.dispose();
  });

  test('should handle large data sets efficiently', () async {
    // Create a large list of sample data
    final largeList = List.generate(1000, (_) => sampleJson);
    final largeListJson = jsonEncode(largeList);
    
    // Measure performance
    final stopwatch = Stopwatch()..start();
    final result = await isolate.parseListData(
      largeListJson,
      Data.parseDataList,
    );
    stopwatch.stop();
    
    expect(result.length, equals(1000));
    print('Time to parse 1000 objects: ${stopwatch.elapsedMilliseconds}ms');
  });
}