import 'package:uresaxapp/apis/http-client.dart';

class NcfType {
  int? id;
  String name;
  String? ncfTag;

  NcfType({this.id, required this.name,this.ncfTag});

  static Future<List<NcfType>> getNcfTypes() async {
    try {
      var response = await httpClient.get('/ncfs');
      return (response.data as List)
          .map((e) => 
           NcfType.fromJson(e))
          .toList()
          .cast<NcfType>();
    } catch (e) {
      rethrow;
    }
  }

  factory NcfType.fromJson(Map<String, dynamic> json) {
    return NcfType(id: json['id'], name: json['name'],ncfTag: json['ncf_tag']);
  }

  toMap() {
    return {'id': id, 'name': name,'ncf_tag':ncfTag};
  }
}
