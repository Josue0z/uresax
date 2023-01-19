import 'package:uresaxapp/apis/connection.dart';

class PaymentMethod {
  int? id;
  String name;
  DateTime? createdAt;
  PaymentMethod({this.id, required this.name, this.createdAt});

  static Future<List<PaymentMethod>> getPaymentMethods() async {
    var results = await connection
        .mappedResultsQuery('''select * from public."PaymentMethod";''');
    return results
        .map((e) => PaymentMethod.fromJson(e['PaymentMethod']!))
        .toList();
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
        id: json['id'],
        name: json['name'],
        createdAt:json['created_at']);
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
