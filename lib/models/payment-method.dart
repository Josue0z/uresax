import 'package:uresaxapp/apis/connection.dart';

class PaymentMethod {
  int? id;
  String name;
  String? invoiceTypeValue;
  DateTime? createdAt;
  PaymentMethod(
      {this.id, this.invoiceTypeValue, required this.name, this.createdAt});

  String get fullName {
    if (invoiceTypeValue == null) return name;
    return '$invoiceTypeValue-$name';
  }

  static Future<List<PaymentMethod>> getPaymentMethods() async {
    var results = await connection
        .mappedResultsQuery('''select * from public."PaymentMethod" order by id;''');
    return results
        .map((e) => PaymentMethod.fromJson(e['PaymentMethod']!))
        .toList();
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
        id: json['id'],
        name: json['name'],
        invoiceTypeValue: json['invoice_type_value'],
        createdAt: json['created_at']);
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'invoice_type_value': invoiceTypeValue,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
