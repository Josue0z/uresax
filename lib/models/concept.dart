import 'package:uresaxapp/apis/connection.dart';

class Concept {
  int? id;
  String? name;
  DateTime? createdAt;
  Concept({this.id, this.name, this.createdAt});

  static getConcepts() async {
     try{
      var results = await connection.mappedResultsQuery('''SELECT * FROM public."Concept";''');
      return results.map((e) => Concept.fromJson(e['Concept']!)).toList();
     }catch(e){
      rethrow;
     }
  }

  factory Concept.fromJson(Map<String, dynamic> map) {
    return Concept(
        id: map['id'],
        name: map['name'],
        createdAt: map['created_at']);
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
