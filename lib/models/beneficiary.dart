import 'dart:convert';
import 'package:uresaxapp/apis/connection.dart';

class Beneficiary {
  int? id;
  String? name;
  DateTime? createdAt;
  Beneficiary({
    this.id,
    required this.name,
    this.createdAt,
  });

  Future<void> create() async {
    try {
      await connection.mappedResultsQuery(
          ''' insert into public."Beneficiary"(name) values('$name') ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update() async {
    try {
      await connection.mappedResultsQuery(
          ''' update public."Beneficiary" set name = '$name' where id = '$id' ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      await connection.mappedResultsQuery(
          ''' delete from public."Beneficiary" where id = $id ''');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Beneficiary> findById(int id) async {
    try {
      var result = await connection.mappedResultsQuery(
          ''' select * from public."Beneficiary" where id = $id ''');
      return Beneficiary.fromMap(result.first['Beneficiary']!);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Beneficiary>> get({
    String words = '',
    bool searchMode = false
  }) async {
    try {
      var searchContext = '';
      if(words != '' && searchMode){
        searchContext = ''' where "name" like '%$words%' ''';
      }
      var results = await connection.mappedResultsQuery(
          ''' select * from public."Beneficiary" $searchContext order by name ''');
      return results
          .map((e) => Beneficiary.fromMap(e['Beneficiary']!))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Beneficiary copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Beneficiary(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    if (name != null) {
      result.addAll({'name': name});
    }
    if (createdAt != null) {
      result.addAll({'createdAt': createdAt!.millisecondsSinceEpoch});
    }

    return result;
  }

  factory Beneficiary.fromMap(Map<String, dynamic> map) {
    return Beneficiary(
      id: map['id']?.toInt(),
      name: map['name'],
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Beneficiary.fromJson(String source) =>
      Beneficiary.fromMap(json.decode(source));

  @override
  String toString() =>
      'Beneficiary(id: $id, name: $name, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Beneficiary &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ createdAt.hashCode;
}
