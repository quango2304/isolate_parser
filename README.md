# Isolate JSON Parser

A Dart package that provides a mechanism for decoding JSON strings into Dart objects and parsing JSON to data models efficiently within a single isolate.

## Features

- Parses JSON data in a background isolate for improved performance.
- Supports parsing single data objects and lists of data objects.
- Provides an abstract interface for parsing, making it easy to integrate with your data models.
- use only 1 single isolate to handle parsing data, which help reduce memory usage and faster than
  using compute function.

## Initialize the Parser

```
final IsolateParserInterface parser = IsolateParser();
// Initialize the parser
parser.init();
```

## Parse a Single Data Object
```
...
  static Data fromJson(Map<String, dynamic> json) {
    return Data(
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      hobbies: List<String>.from(json['hobbies'] as List),
    );
  }
...
final jsonString = '{"name": "John Doe", "age": 30}';

final data = await parser.parseData(jsonString, Data.fromJson);

print('Parsed Data - Name: ${data.name}, Age: ${data.age}');
```

### Parse a List of Data Objects
```
...
  static List<Data> parseDataList(List<dynamic> jsonList) {
    List<Data> dataList = [];
    for (var jsonData in jsonList) {
      if (jsonData is Map<String, dynamic>) {
        dataList.add(Data.fromJson(jsonData));
      }
    }
    return dataList;
  }
 ...
final jsonListString = '[{"name": "John", "age": 30}, {"name": "Alice", "age": 25}]';

final dataList = await parser.parseListData(jsonListString, Data.parseDataList);
```

### Note

- parser function must be a static or global method
- should call dispose when no longer use the parser to kill the isolate