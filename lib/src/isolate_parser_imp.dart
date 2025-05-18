import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:uuid/uuid.dart';

import 'isolate_parser_interface.dart';

part 'models.dart';

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
  void init() async {
    _isolate = await Isolate.spawn(
      _isolateFunc,
      _mainReceivePort.sendPort,
    );
    _listenToData();
  }

  @override
  Future<Result> parseData<Result>(
    String dataNeedParse,
    MapParser<Result> parser,
  ) async {
    await _initCompleter.future;
    return _parseData(dataNeedParse, parser);
  }

  @override
  Future<List<Result>> parseListData<Result>(
    String dataNeedParse,
    ListParser<Result> parser,
  ) async {
    await _initCompleter.future;
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
