import 'package:uresaxapp/apis/http-client.dart';

class InvoiceType {
  int? id;
  String name;
  DateTime? createdAt;
  InvoiceType({this.id, required this.name, this.createdAt});

  
  static Future<List<InvoiceType>> getInvoicesTypes()async{
     var response = await httpClient.get('/invoices-types');
     return (response.data as List).map((e) => InvoiceType.fromJson(e)).toList().cast<InvoiceType>();
  }

  factory InvoiceType.fromJson(Map<String, dynamic> json) {
    return InvoiceType(
        id: json['id'],
        name: json['name'],
        createdAt: DateTime.tryParse(json['created_at']));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
