import 'package:uresaxapp/apis/connection.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uuid/uuid.dart';

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

  Future<List<Purchase>> getPurchases(
      {String startDate = '', String endDate = ''}) async {
    try {
      var results = await connection.mappedResultsQuery(
          '''SELECT * FROM public."PurchaseDetails" WHERE "invoice_issue_date" between '$startDate' and '$endDate' order by "invoice_company_name","invoice_ncf";''');
      return results.map((row) => Purchase.fromMap(row['']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Sheet> create() async {
    try {
      id = const Uuid().v4();

      var r = await connection.query(
          '''select * from public."Sheet" where "bookId" = '$bookId' and "sheet_year" = $sheetYear and "sheet_month" = $sheetMonth;''');

      if (r.isNotEmpty) {
        throw 'YA EXISTE ESTA HOJA';
      }
      await connection.query(
          '''insert into public."Sheet"("id","bookId","companyId","sheet_year","sheet_month") values('$id','$bookId','$companyId','$sheetYear','$sheetMonth');''');
      var results = await connection.mappedResultsQuery(
          '''select * from public."SheetDetails" where "id" = '$id';''');
      return Sheet.fromJson(results.first['']!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      await connection.query(
          '''DELETE FROM public."Purchase" WHERE "invoice_sheetId" = '$id';''');
      await connection
          .query('''DELETE FROM public."Sheet" WHERE "id" = '$id';''');
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'companyId': companyId,
      'sheet_year': sheetYear,
      'sheet_month': sheetMonth,
      'sheet_date': sheetDate,
      'present_status': presentStatus,
      'present_status_name': presentStatusName,
      'updated_at': updatedAt?.toUtc().toString(),
      'created_at': createdAt?.toUtc().toString()
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
        updatedAt: json['updated_at'],
        createdAt: json['created_at']);
  }
}
