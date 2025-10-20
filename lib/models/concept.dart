import 'package:uresaxapp/apis/connection.dart';

class Concept {
  int? id;
  String? name;
  DateTime? createdAt;
  int? typeContextId;
  String? typeContextName;
  Concept(
      {this.id,
      this.name,
      this.createdAt,
      this.typeContextId,
      this.typeContextName});

  static Future<List<Concept>> getConcepts(
      {String words = '', bool searchMode = false}) async {
    try {
      var searchContext = '';

      if (searchMode && words.isNotEmpty) {
        searchContext = ''' where upper("name") like upper('%$words%') ''';
      }

      var results = await connection.mappedResultsQuery(
          '''SELECT * FROM public."Concept" $searchContext ORDER BY name;''');
      return results.map((e) => Concept.fromJson(e['Concept']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Concept> create() async {
    try {
      var r = await connection.mappedResultsQuery(
          '''SELECT * FROM public."Concept" WHERE name = '$name';''');

      if (r.isNotEmpty) {
        throw 'YA EXISTE ESTE CONCEPTO';
      }
      await connection
          .query('''INSERT INTO public."Concept"(name) VALUES('$name');''');
      var results = await connection.mappedResultsQuery(
          '''SELECT * FROM public."Concept" ORDER BY name DESC LIMIT 1;''');
      return Concept.fromJson(results.first['Concept']!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Concept> update() async {
    try {
      await connection.query(
          '''UPDATE public."Concept" SET name = '$name', "typeContextId" = $typeContextId WHERE "id" = $id;''');
      var results = await connection.mappedResultsQuery(
          '''SELECT * FROM public."Concept" WHERE "id" = $id;''');

      return Concept.fromJson(results.first['Concept']!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      await connection
          .query('''DELETE FROM public."Concept"  WHERE "id" = $id;''');
    } catch (e) {
      rethrow;
    }
  }

  factory Concept.fromJson(Map<String, dynamic> map) {
    return Concept(
        id: map['id'],
        name: map['name'],
        typeContextId: map['typeContextId'],
        typeContextName: map['typeContextName'],
        createdAt: map['created_at']);
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'typeContextId': typeContextId,
      'typeContextName': typeContextName,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
