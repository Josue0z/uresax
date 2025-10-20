// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';

class NcfTypeOverride {
  String? code;
  String? name;
  DateTime? createdAt;
  NcfTypeOverride({
    this.code,
    this.name,
    this.createdAt,
  });

  static Future<List<NcfTypeOverride>> get() async {
    try {
      var res = await connection.mappedResultsQuery(
          '''select * from public."CancellationCodeTable" order by code;''');
      return res
          .map((e) => NcfTypeOverride.fromMap(e['CancellationCodeTable']!))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

    

  NcfTypeOverride copyWith({
    String? code,
    String? name,
    DateTime? createdAt,
  }) {
    return NcfTypeOverride(
      code: code ?? this.code,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'name': name,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory NcfTypeOverride.fromMap(Map<String, dynamic> map) {
    return NcfTypeOverride(
      code: map['code'] as String,
      name: map['name'] as String,
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NcfTypeOverride.fromJson(String source) =>
      NcfTypeOverride.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'NcfTypeOverride(code: $code, name: $name, createdAt: $createdAt)';

  @override
  bool operator ==(covariant NcfTypeOverride other) {
    if (identical(this, other)) return true;

    return other.code == code &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ createdAt.hashCode;
}
