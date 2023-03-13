import 'package:uresaxapp/models/sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:uresaxapp/apis/connection.dart';

enum BookType { purchases, sales }

class Book {
  String? id;
  String? name;
  int? year;
  String? companyRnc;
  String? companyName;
  String? companyId;
  String? latestSheetVisited;
  int? bookTypeId;
  String? bookTypeName;
  BookType? bookType;
  DateTime? updatedAt;
  DateTime? createdAt;
  Book(
      {this.id,
      this.name,
      this.year,
      this.companyRnc,
      this.companyName,
      this.companyId,
      this.latestSheetVisited,
      this.bookTypeId,
      this.bookTypeName,
      this.updatedAt,
      this.bookType,
      this.createdAt});

  Future<Book> create() async {
    try {
      var id = const Uuid().v4();

      await connection.query('''
        insert into public."Book"("id","book_year","company_rnc","companyId","book_typeId") values('$id',$year,'$companyRnc','$companyId',$bookTypeId); 
       ''');
      var results = await connection.mappedResultsQuery(
          '''select * from public."BookDetails" where "id" = '$id';''');

      return Book.fromJson(results.first['']!);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Book>> all({String? companyId}) async {
    try {
      var results = await connection.mappedResultsQuery('''
      select * from public."BookDetails" where "companyId" = '$companyId' and "book_typeId" = 1 order by "book_year";
     ''');
      return results.map((row) => Book.fromJson(row['']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Sheet>> getSheets() async {
    try {
      var results = await connection.mappedResultsQuery(
          '''select * from public."SheetDetails" where "bookId" = '$id' order by "sheet_year","sheet_month";''');

      return results
          .map((row) => Sheet.fromJson(row['']!))
          .toList()
          .cast<Sheet>();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLatestSheetVisited() async {
    try {
      await connection.query(
          '''update public."Book" set "latest_sheet_visited" = '$latestSheetVisited' where "id" = '$id';''');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfBookIsUsed() async {
    try {
      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM public."Book" WHERE "id" = '$id' and "in_use" = true;''');

      if (result.isNotEmpty) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<void> updateBookUseStatus(bool status) async {
    try {
      await connection.query(
          '''UPDATE public."Book" SET in_use = $status WHERE "id" = '$id';''');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      await connection.transaction((c) async {
        await c.query(
            '''DELETE FROM public."Purchase" WHERE "invoice_bookId" = '$id';''');
        await c.query('''DELETE FROM public."Sheet" WHERE "bookId" = '$id';''');
        await c.query('''DELETE FROM public."Book" WHERE "id" = '$id';''');
      });
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_name': name,
      'book_year': year,
      'company_rnc': companyRnc,
      'companyId': companyId,
      'latest_sheet_visited': latestSheetVisited,
      'company_name': companyName,
      'book_typeId': bookTypeId,
      'book_type_name': bookTypeName,
      'updated_at': updatedAt,
      'created_at': createdAt
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
        id: json['id'],
        name: json['book_name'],
        year: json['book_year'],
        companyRnc: json['company_rnc'],
        companyName: json['company_name'],
        companyId: json['companyId'],
        latestSheetVisited: json['latest_sheet_visited'],
        bookTypeId: json['book_typeId'],
        bookTypeName: json['book_type_name'],
        bookType:
            json['book_typeId'] == 1 ? BookType.purchases : BookType.sales,
        updatedAt: json['updated_at'],
        createdAt: json['created_at']);
  }
}
