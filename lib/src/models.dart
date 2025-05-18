part of 'isolate_parser_imp.dart';

typedef MapParser<Result> = Result Function(Map<String, dynamic> json);
typedef ListParser<Result> = List<Result> Function(List<dynamic> jsonList);

class _MainToIsolateMessage<Result, Parser> {
  final Parser parser;
  final String taskId;
  final String dataNeedParse;

  _MainToIsolateMessage({
    required this.parser,
    required this.taskId,
    required this.dataNeedParse,
  });
}

class _IsolateToMainMessage<Result> {
  final String taskId;
  final Result result;

  _IsolateToMainMessage({
    required this.taskId,
    required this.result,
  });
}

class _IsolateToMainError {
  final String taskId;
  final Object error;
  final StackTrace stackTrace;

  _IsolateToMainError({
    required this.taskId,
    required this.stackTrace,
    required this.error,
  });
}
