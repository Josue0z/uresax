// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';



class PermissionC {
   int id;
   String name;
   String displayName;
   DateTime createdAt;
  PermissionC({
    required this.id,
    required this.name,
    required this.displayName,
    required this.createdAt,
  });

  static Future<List<PermissionC>> get()async{
     try{
      var res = await connection.mappedResultsQuery('''select * from public."Permissions" order by "createdAt";''');
      return res.map((e) => PermissionC.fromMap(e['Permissions']!)).toList();
     }catch(e){
      rethrow;
     }
  }

  PermissionC copyWith({
    int? id,
    String? name,
    String? displayName,
    DateTime? createdAt,
  }) {
    return PermissionC(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'displayName': displayName,
      'createdAt': createdAt.toString(),
    };
  }

  factory PermissionC.fromMap(Map<String, dynamic> map) {
    return PermissionC(
      id: map['id'] as int,
      name: map['name'] as String,
      displayName: map['displayName'] as String,
      createdAt:map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PermissionC.fromJson(String source) => PermissionC.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PermissionC(id: $id, name: $name, displayName: $displayName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant PermissionC other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.displayName == displayName &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      displayName.hashCode ^
      createdAt.hashCode;
  }
}
