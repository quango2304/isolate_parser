import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:uuid/uuid.dart';

part 'models.dart';

/// An abstract class representing an interface for parsing json data in a background isolate.
///
/// This interface defines methods for initializing the isolate, parsing single data objects,
/// and parsing lists of data objects.
abstract class IsolateParserInterface {
  /// Initializes the isolate for parsing data.
  ///
  /// This method should be called before using the isolate for parsing data.
  /// It sets up the necessary resources and prepares the isolate for parsing.
  Future<void> init();

  /// Parses a single data object using the provided [parser].
  ///
  /// This method takes the [dataNeedParse] as input and a [parser] function
  /// to parse the data into the specified [Result] type.
  /// It runs the parsing operation in the background isolate.
  /// sample [../test/test.dart]
  /// Returns a `Future` containing the parsed result.
  /// parser function must be a static or global method
  Future<Result> parseData<Result>(
    String dataNeedParse,
    MapParser<Result> parser,
  );

  /// Parses a list of data objects using the provided [parser].
  ///
  /// This method takes the [dataNeedParse] as input and a [parser] function
  /// to parse each item in the list into the specified [Result] type.
  /// It runs the parsing operation in the background isolate.
  /// sample [../test/test.dart]
  /// Returns a `Future` containing a list of parsed results.
  /// parser function must be a static or global method
  Future<List<Result>> parseListData<Result>(
    String dataNeedParse,
    ListParser<Result> parser,
  );

  ///call when don't need to use the isolate anymore
  ///this will kill the isolate, close the port
  void dispose();
}

class IsolateParser implements IsolateParserInterface {
  ///use to receive data from isolate send to main
  final ReceivePort _mainReceivePort = ReceivePort();

  ///use to send data from main to isolate
  late SendPort _sendToIsolatePort;

  //store running tasks that is parsing inside isolate
  final Map<String, Completer> _runningTasksMap = {};

  final _initCompleter = Completer();

  Isolate? _isolate;

  StreamSubscription? _sub;

  @override
  Future<void> init() async {
    _isolate = await Isolate.spawn(
      _isolateFunc,
      _mainReceivePort.sendPort,
    );
    _listenToData();
    return _initCompleter.future;
  }

  @override
  Future<Result> parseData<Result>(
    String dataNeedParse,
    MapParser<Result> parser,
  ) async {
    assert(_initCompleter.isCompleted == true, "must call init first");
    return _parseData(dataNeedParse, parser);
  }

  @override
  Future<List<Result>> parseListData<Result>(
    String dataNeedParse,
    ListParser<Result> parser,
  ) async {
    assert(_initCompleter.isCompleted == true, "must call init first");
    return _parseData(dataNeedParse, parser);
  }

  ///listen to parsed data from the isolate
  void _listenToData() {
    _sub = _mainReceivePort.listen((isolateToMainMessage) {
      if (isolateToMainMessage is _IsolateToMainMessage) {
        //parse successful case
        final data = isolateToMainMessage.result;
        _runningTasksMap[isolateToMainMessage.taskId]?.complete(data);
        _runningTasksMap.remove(isolateToMainMessage.taskId);
      } else if (isolateToMainMessage is _IsolateToMainError) {
        //parse error case
        _runningTasksMap[isolateToMainMessage.taskId]?.completeError(
          isolateToMainMessage.error,
          isolateToMainMessage.stackTrace,
        );
        _runningTasksMap.remove(isolateToMainMessage.taskId);
      } else if (isolateToMainMessage is SendPort) {
        //get the send port from isolate, only run in the first time init
        _sendToIsolatePort = isolateToMainMessage;
        _initCompleter.complete();
      }
    });
  }

  Future<Result> _parseData<Result, Parser>(
    String dataNeedParse,
    Parser parser,
  ) {
    final taskId = const Uuid().v1();
    final completer = Completer<Result>();
    _runningTasksMap[taskId] = completer;
    _sendToIsolatePort.send(_MainToIsolateMessage(
      dataNeedParse: dataNeedParse,
      taskId: taskId,
      parser: parser,
    ));
    return completer.future;
  }

  static void _isolateFunc(SendPort sendToMainPort) {
    final isolateReceivePort = ReceivePort();
    sendToMainPort.send(isolateReceivePort.sendPort);
    isolateReceivePort.listen((mainToIsolateMessage) {
      if (mainToIsolateMessage is _MainToIsolateMessage) {
        try {
          final dataDecoded = jsonDecode(mainToIsolateMessage.dataNeedParse);
          final dataParsed = mainToIsolateMessage.parser(dataDecoded);
          sendToMainPort.send(_IsolateToMainMessage(
            taskId: mainToIsolateMessage.taskId,
            result: dataParsed,
          ));
        } catch (e, s) {
          sendToMainPort.send(_IsolateToMainError(
            taskId: mainToIsolateMessage.taskId,
            error: e,
            stackTrace: s,
          ));
        }
      }
    });
  }

  @override
  void dispose() {
    _isolate?.kill();
    _sub?.cancel();
    _mainReceivePort.close();
  }
}
