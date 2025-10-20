import 'package:uresaxapp/apis/connection.dart';

class NcfType {
  int? id;
  int? prefixId;
  String name;
  String? ncfTag;
  String? invoiceTypeValue;

  NcfType(
      {this.id,
      this.ncfTag,
      this.prefixId,
      this.invoiceTypeValue,
      required this.name});

  static Future<List<NcfType>> getNcfs() async {
    var response = await connection.mappedResultsQuery(
        '''select * from public."NcfTypeView" ORDER BY id;''');

    var results = response.map((row) => NcfType.fromJson(row['']!)).toList();
    return results;
  }

  String get fullName {
    if (invoiceTypeValue == null) return name;
    return '$invoiceTypeValue-$name';
  }

  factory NcfType.fromJson(Map<String, dynamic> json) {
    return NcfType(
        id: json['id'],
        name: json['name'],
        ncfTag: json['ncf_tag'],
        prefixId: json['prefixId'],
        invoiceTypeValue: json['invoice_type_value']);
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'ncf_tag': ncfTag,
      'prefixId': prefixId,
      'invoice_type_value': invoiceTypeValue
    };
  }
}
