import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';


class Role {
  int? id;
  String? name;
  Role({
    this.id,
    this.name,
  });

  static Future<List<Role>> all()async{
     try{
        var result =  await connection.mappedResultsQuery('''SELECT * FROM public."Role"''');
        return result.map((e) => Role.fromMap(e['Role']!)).toList();
     }catch(e){
      rethrow;
     }
  }

  Role copyWith({
    int? id,
    String? name,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    if(id != null){
      result.addAll({'id': id});
    }
    if(name != null){
      result.addAll({'name': name});
    }
  
    return result;
  }

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id']?.toInt(),
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Role.fromJson(String source) => Role.fromMap(json.decode(source));

  @override
  String toString() => 'Role(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Role &&
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
