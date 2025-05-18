import '../isolate_parser.dart';

/// An abstract class representing an interface for parsing json data in a background isolate.
///
/// This interface defines methods for initializing the isolate, parsing single data objects,
/// and parsing lists of data objects.
abstract class IsolateParserInterface {
  /// Initializes the isolate for parsing data.
  ///
  /// This method should be called before using the isolate for parsing data.
  /// It sets up the necessary resources and prepares the isolate for parsing.
  /// this is not a future task so you should call it as soon as possible, could be in run app method
  void init();

  /// Parses a single data object using the provided [parser].
  ///
  /// This method takes the [dataNeedParse] as input and a [parser] function
  /// to parse the data into the specified [Result] type.
  /// It runs the parsing operation in the background isolate.
  /// sample [../test/isolate_parser_imp_test.dart]
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
  /// sample [../test/isolate_parser_imp_test.dart]
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
