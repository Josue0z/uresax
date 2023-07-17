import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';

class PhysicalPerson {
  String id;
  String name;
  PhysicalPerson({
    required this.id,
    required this.name,
  });

  static Future<List<PhysicalPerson>> get() async {
    try {
      var results = await connection
          .mappedResultsQuery('''select * from public."Providers";''');
      return results
          .map((e) => PhysicalPerson.fromMap(e['Providers']!))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PhysicalPerson> create() async {
    try {
      await connection.execute(
          '''insert into public."Providers"(id,name) values('$id','$name');''');
      var res = await connection.mappedResultsQuery(
          '''select * from public."Providers" where "id" = '$id' ''');
      return PhysicalPerson.fromMap(res.first['Providers']!);
    } catch (e) {
      rethrow;
    }
  }

  delete() async {
    try {
      await connection.execute(''' delete from public."Providers" where "id" = '$id' ''');
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});

    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PhysicalPerson && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  PhysicalPerson copyWith({
    String? id,
    String? name,
  }) {
    return PhysicalPerson(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory PhysicalPerson.fromMap(Map<String, dynamic> map) {
    return PhysicalPerson(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }

  factory PhysicalPerson.fromJson(String source) =>
      PhysicalPerson.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'PhysicalPerson(id: $id, name: $name)';
}
