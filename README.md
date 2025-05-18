# Isolate JSON Parser

[![pub package](https://img.shields.io/pub/v/isolate_parser.svg)](https://pub.dev/packages/isolate_parser)

A Dart package that provides a mechanism for decoding JSON strings into Dart objects and parsing JSON to data models efficiently within a single isolate.

## Features

- Parses JSON data in a background isolate for improved performance
- Supports parsing single data objects and lists of data objects
- Provides an abstract interface for parsing, making it easy to integrate with your data models
- Uses only a single isolate to handle parsing data, which reduces memory usage and is faster than using Flutter's `compute` function
- Works with both Flutter and pure Dart projects

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  isolate_parser: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Initialize the Parser

```dart
final IsolateParserInterface parser = IsolateParser();
// Initialize the parser
await parser.init();
```

## Usage

### Parse a Single Data Object

First, define your data model with a static `fromJson` method:

```dart
class Data {
  final String name;
  final int age;
  
  Data({required this.name, required this.age});
  
  static Data fromJson(Map<String, dynamic> json) {
    return Data(
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }
}
```

Then use the parser to parse your JSON string:

```dart
final jsonString = '{"name": "John Doe", "age": 30}';

final data = await parser.parseData(jsonString, Data.fromJson);

print('Parsed Data - Name: ${data.name}, Age: ${data.age}');
```

### Parse a List of Data Objects

Define a static method to parse a list of objects:

```dart
class Data {
  // ... properties and constructor
  
  static List<Data> parseDataList(List<dynamic> jsonList) {
    List<Data> dataList = [];
    for (var jsonData in jsonList) {
      if (jsonData is Map<String, dynamic>) {
        dataList.add(Data.fromJson(jsonData));
      }
    }
    return dataList;
  }
}
```

Then use the parser to parse your JSON array string:

```dart
final jsonListString = '[{"name": "John", "age": 30}, {"name": "Alice", "age": 25}]';

final dataList = await parser.parseListData(jsonListString, Data.parseDataList);
```

## Important Notes

- The parser function must be a static or global method to be accessible from the isolate
- Always call `dispose()` when you no longer need the parser to properly terminate the isolate:

```dart
// When you're done with the parser
await parser.dispose();
```

## Performance Benefits

Using a single dedicated isolate for JSON parsing offers several advantages:

- Offloads parsing work from the main UI thread, preventing jank
- More efficient than creating a new isolate for each parsing operation
- Reduces memory overhead compared to multiple isolates
- Faster than Flutter's `compute` function for repeated parsing operations

## License

This project is licensed under the MIT License - see the LICENSE file for details.
