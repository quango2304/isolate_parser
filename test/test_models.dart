final sampleJson = {
  "person": {"name": "John Doe", "age": 30, "email": "johndoe@example.com"},
  "address": {
    "street": "123 Main Street",
    "city": "New York",
    "zipcode": "10001"
  },
  "hobbies": ["Reading", "Hiking", "Cooking"]
};

class Person {
  final String name;
  final int age;
  final String email;

  Person({
    required this.name,
    required this.age,
    required this.email,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'] as String,
      age: json['age'] as int,
      email: json['email'] as String,
    );
  }
}

class Address {
  final String street;
  final String city;
  final String zipcode;

  Address({
    required this.street,
    required this.city,
    required this.zipcode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      city: json['city'] as String,
      zipcode: json['zipcode'] as String,
    );
  }
}

class Data {
  final Person person;
  final Address address;
  final List<String> hobbies;

  Data({
    required this.person,
    required this.address,
    required this.hobbies,
  });

  static Data fromJson(Map<String, dynamic> json) {
    return Data(
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      hobbies: List<String>.from(json['hobbies'] as List),
    );
  }

  static Data fromJsonError(Map<String, dynamic> json) {
    return Data(
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      hobbies: List<String>.from(json['hobbies'] as List<int>),
    );
  }

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