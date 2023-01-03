import 'package:uresaxapp/apis/http-client.dart';

class Banking {
  int? id;
  String name;
  String? bankingRnc;
  DateTime? createdAt;
  Banking({this.id, required this.name, this.bankingRnc, this.createdAt});

  static Future<List<Banking>> getBankings() async {
    try {
      var response = await httpClient.get('/bankings');
      return (response.data as List)
          .map((e) => Banking.fromJson(e)).toList().cast<Banking>();
    } catch (e) {
      rethrow;
    }
  }

  factory Banking.fromJson(Map<String, dynamic> json) {
    return Banking(
        id: json['id'],
        name: json['name'],
        bankingRnc: json['banking_rnc'],
        createdAt: DateTime.tryParse(json['created_at']));
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'banking_rnc': bankingRnc,
      'created_at': createdAt?.toUtc().toString()
    };
  }
}
