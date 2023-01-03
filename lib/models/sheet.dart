import 'package:uresaxapp/apis/http-client.dart';

class Sheet {
  String? id;
  String? bookId;
  String? companyId;
  String? companyName;
  int? sheetYear;
  int? sheetMonth;
  String? sheetDate;
  int? presentStatus;
  String? presentStatusName;
  DateTime? updatedAt;
  DateTime? createdAt;

  Sheet(
      {this.id,
      this.bookId,
      this.companyId,
      this.companyName,
      this.sheetYear,
      this.sheetMonth,
      this.sheetDate,
      this.presentStatus,
      this.presentStatusName,
      this.updatedAt,
      this.createdAt});

  static Future<List<Sheet>> getSheetsByBookId({String bookId = ''}) async {
    try {
      var response = await httpClient.get('/sheets?bookId=$bookId');
      return (response.data as List)
          .map((json) => Sheet.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Sheet> create() async {
    try {
      var map = toMap();
      map.removeWhere((key, value) => value == null);
      var response = await httpClient.post('/sheets', data:map);
      return Sheet.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  Map<String,dynamic>  toMap(){
    return {
      'id':id,
      'bookId':bookId,
      'companyId':companyId,
      'sheet_year':sheetYear,
      'sheet_month':sheetMonth,
      'sheet_date':sheetDate,
      'present_status':presentStatus,
      'present_status_name':presentStatusName,
      'updated_at':updatedAt?.toUtc().toString(),
      'created_at':createdAt?.toUtc().toString()
    };
   }
  factory Sheet.fromJson(Map<String, dynamic> json) {
    return Sheet(
        id: json['id'],
        bookId: json['bookId'],
        companyId: json['companyId'],
        companyName: json['company_name'],
        sheetYear: json['sheet_year'],
        sheetMonth: json['sheet_month'],
        sheetDate: json['sheet_date'],
        presentStatus: json['present_status'],
        presentStatusName: json['present_status_name'],
        updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
        createdAt: DateTime.tryParse(json['created_at']));
  }
}
