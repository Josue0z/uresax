import 'package:uresaxapp/apis/connection.dart';

class InvoiceType {
  int? id;
  String name;
  DateTime? createdAt;
  InvoiceType({this.id, required this.name, this.createdAt});

  static Future<List<InvoiceType>> getInvoiceTypes() async {
    var results = await connection
        .mappedResultsQuery('''select * from public."InvoiceType";''');
    return results.map((e) => InvoiceType.fromJson(e['InvoiceType']!)).toList();
  }

  factory InvoiceType.fromJson(Map<String, dynamic> json) {
    return InvoiceType(
        id: json['id'],
        name: json['name'],
        createdAt: json['created_at']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
