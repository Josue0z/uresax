// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uresaxapp/apis/connection.dart';

class InvoiceTypeContext {
  int id;
  String name;
  InvoiceTypeContext({
    required this.id,
    required this.name,
  });

  static Future<List<InvoiceTypeContext>> get() async {
    try {
      var res = await connection.mappedResultsQuery(
          ''' select * from public."PurchaseType"; ''');
      return res
          .map((e) => InvoiceTypeContext.fromMap(e['PurchaseType']!))
          .toList();
    } catch (e) {
      rethrow;
    }
  }



  InvoiceTypeContext copyWith({
    int? id,
    String? name,
  }) {
    return InvoiceTypeContext(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory InvoiceTypeContext.fromMap(Map<String, dynamic> map) {
    return InvoiceTypeContext(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory InvoiceTypeContext.fromJson(String source) =>
      InvoiceTypeContext.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'InvoiceTypeContext(id: $id, name: $name)';

  @override
  bool operator ==(covariant InvoiceTypeContext other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
