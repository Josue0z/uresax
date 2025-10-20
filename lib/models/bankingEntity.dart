import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';

class BankingEntity {
  int? id;
  String? name;
  BankingEntity({this.id, this.name});

  static Future<List<BankingEntity>> get() async {
    try {
      var result = await connection
          .mappedResultsQuery(''' select * from public."BankingEntity" ''');
      return result
          .map((e) => BankingEntity.fromMap(e['BankingEntity']!))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  BankingEntity copyWith({
    int? id,
    String? name,
  }) {
    return BankingEntity(
      id: id ?? this.id,
      name: name ?? this.name,
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

    return result;
  }

  factory BankingEntity.fromMap(Map<String, dynamic> map) {
    return BankingEntity(
      id: map['id']?.toInt(),
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BankingEntity.fromJson(String source) =>
      BankingEntity.fromMap(json.decode(source));

  @override
  String toString() => 'BankingEntity(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BankingEntity && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
