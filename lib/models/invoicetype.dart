import 'package:uresaxapp/apis/connection.dart';

class InvoiceType {
  int? id;
  String? invoiceTypeValue;
  String name;
  DateTime? createdAt;
  InvoiceType(
      {this.id, this.invoiceTypeValue, required this.name, this.createdAt});


  String get fullName {
    if(invoiceTypeValue == null) return name;
    return '$invoiceTypeValue-$name';
  }

  static Future<List<InvoiceType>> getInvoiceTypes() async {
    var results = await connection
        .mappedResultsQuery('''select * from public."InvoiceType" order by id;''');
    return results.map((e) => InvoiceType.fromJson(e['InvoiceType']!)).toList();
  }

  factory InvoiceType.fromJson(Map<String, dynamic> json) {
    return InvoiceType(
        id: json['id'],
        name: json['name'],
        invoiceTypeValue: json['invoice_type_value'],
        createdAt: json['created_at']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'invoice_type_value': invoiceTypeValue,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
