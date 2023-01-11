import 'package:uresaxapp/apis/http-client.dart';

class Concept {
  int? id;
  String? name;
  DateTime? createdAt;

  Concept({this.id, this.name, this.createdAt});

  static getConcepts() async {
    try {
      var result = await httpClient.get('/concepts');
      return (result.data as List).map((e) => Concept.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  factory Concept.fromJson(Map<String, dynamic> map) {
    return Concept(
        id: map['id'],
        name: map['name'],
        createdAt: DateTime.tryParse(map['created_at']));
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
