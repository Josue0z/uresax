import 'dart:convert';
import 'package:uresaxapp/apis/connection.dart';

class TypeOfIncome {
  String? id;
  String name;
  TypeOfIncome({
    this.id,
    required this.name,
  });

  static Future<List<TypeOfIncome>> get() async {
    try {
      var results = await connection
          .mappedResultsQuery(''' select * from public."TypeOfIncome" ''');

        
      return results.map((e) => TypeOfIncome.fromMap(e['TypeOfIncome']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  TypeOfIncome copyWith({
    String? id,
    String? name,
  }) {
    return TypeOfIncome(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    if(id != null){
      result.addAll({'id': id});
    }
    result.addAll({'name': name});
  
    return result;
  }

  factory TypeOfIncome.fromMap(Map<String, dynamic> map) {
    return TypeOfIncome(
      id: map['id'],
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TypeOfIncome.fromJson(String source) =>
      TypeOfIncome.fromMap(json.decode(source));

  @override
  String toString() => 'TypeOfIncome(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TypeOfIncome && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
