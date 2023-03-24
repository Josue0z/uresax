import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';

class Tax {
  int id;
  String name;
  int rate;
  DateTime? createdAt;
  Tax({
    required this.id,
    required this.name,
    required this.rate,
    required this.createdAt,
  });


 static Future<List<Tax>> all()async{
      try{
        var result = await connection.mappedResultsQuery('''select * from public."Taxes";''');
        return result.map((e) => Tax.fromMap(e['Taxes']!)).toList();
      }catch(e){
        rethrow;
      }
   }
  

  Tax copyWith({
    int? id,
    String? name,
    int? rate,
    DateTime? createdAt,
  }) {
    return Tax(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'rate': rate});
    result.addAll({'createdAt': createdAt});
  
    return result;
  }

  factory Tax.fromMap(Map<String, dynamic> map) {
    return Tax(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      rate: map['rate']?.toInt() ?? 0,
      createdAt: null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tax.fromJson(String source) => Tax.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Tax(id: $id, name: $name, rate: $rate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Tax &&
      other.id == id &&
      other.name == name &&
      other.rate == rate &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      rate.hashCode ^
      createdAt.hashCode;
  }
}
