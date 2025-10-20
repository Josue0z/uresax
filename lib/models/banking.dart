import 'package:uresaxapp/apis/connection.dart';

class Banking {
  int? id;
  String name;
  String? bankingRnc;
  DateTime? createdAt;
  Banking({this.id, required this.name, this.bankingRnc, this.createdAt});

  static Future<List<Banking>> getBankings() async {
    var results = await connection.mappedResultsQuery(
        '''select * from public."Banking" ORDER BY name;''');
    return results.map((row) => Banking.fromJson(row['Banking']!)).toList();
  }

  factory Banking.fromJson(Map<String, dynamic> json) {
    return Banking(
        id: json['id'],
        name: json['name'],
        bankingRnc: json['banking_rnc'],
        createdAt: json['created_at']);
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
