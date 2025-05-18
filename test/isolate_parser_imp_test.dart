import 'dart:convert';

import 'package:isolate_parser/isolate_parser.dart';
import 'package:isolate_parser/src/isolate_parser_interface.dart';

import 'test_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  IsolateParserInterface isolate = IsolateParser();
  isolate.init();
  final jsonString = jsonEncode(sampleJson);
  final listJson = jsonEncode([sampleJson]);

  test('parseObject', () async {
    final Data result = await isolate.parseData(jsonString, Data.fromJson);
    expect(result, isA<Data>());
  });

  test('parseObjectError', () async {
    bool isError = false;
    try {
      final Data result = await isolate.parseData(
        jsonString,
        Data.fromJsonError,
      );
    } catch (e, s) {
      isError = true;
    }
    expect(isError, equals(true));
  });

  test('parseList', () async {
    final List<Data> result = await isolate.parseListData(
      listJson,
      Data.parseDataList,
    );
    expect(result, isA<List<Data>>());
  });
  tearDownAll(() {
    isolate.dispose();
  });
}
