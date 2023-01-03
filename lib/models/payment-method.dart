import 'package:uresaxapp/apis/http-client.dart';

class PaymentMethod {
  int? id;
  String name;
  DateTime? createdAt;
  PaymentMethod({this.id, required this.name, this.createdAt});

  static Future<List<PaymentMethod>> getPaymentsMethods() async {
    var response = await httpClient.get('/payments-methods');
    return (response.data as List)
        .map((e) => PaymentMethod.fromJson(e))
        .toList()
        .cast<PaymentMethod>();
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
        id: json['id'],
        name: json['name'],
        createdAt: DateTime.tryParse(json['created_at']));
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
