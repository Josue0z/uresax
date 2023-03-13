import 'package:uresaxapp/apis/connection.dart';

class NcfType {
  int? id;
  String name;
  String? ncfTag;
  NcfType({this.id, required this.name, this.ncfTag});

  static Future<List<NcfType>> getNcfs() async {
    var response = await connection
        .mappedResultsQuery('''select * from public."NcfTypeView" ORDER BY id;''');

    var results =
        response.map((row) => NcfType.fromJson(row['']!)).toList();
    return results;
  }

  factory NcfType.fromJson(Map<String, dynamic> json) {
    return NcfType(id: json['id'], name: json['name'], ncfTag: json['ncf_tag']);
  }

  toMap() {
    return {'id': id, 'name': name, 'ncf_tag': ncfTag};
  }
}
