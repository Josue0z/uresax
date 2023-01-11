import 'package:uresaxapp/apis/http-client.dart';

enum BookType { purchases, sales }

class Book {
  String? id;
  String? name;
  int? year;
  String? companyRnc;
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
      this.companyId,
      this.latestSheetVisited,
      this.bookTypeId,
      this.bookTypeName,
      this.updatedAt,
      this.bookType,
      this.createdAt});

  Future<Book?> create() async {
    try {
      var map = toMap();
      map.removeWhere((key, value) => value == null);
      var response = await httpClient.post('/books', data: map);

      return Book.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete()async{
    try{
      await httpClient.delete('/books/$id');
    }catch(e){
      rethrow;
    }
  }

  static Future<List<Book>> getBooks(
      {BookType bookType = BookType.purchases, String? companyId}) async {
    try {
      int type = bookType == BookType.purchases ? 1 : 2;

      String whereContext = '?book_type=$type';

      if (companyId != null && companyId != '') {
        whereContext += '&companyId=$companyId';
      }

      var response = await httpClient.get('/books$whereContext');

      return (response.data as List)
          .map((json) => Book.fromJson(json))
          .toList()
          .cast<Book>();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateLatestSheetVisited(String latestSheetVisited)async{
     try{
      await httpClient.patch('/update-latest-sheet-visited',data: {
        'id':id,
        'latest_sheet_visited':latestSheetVisited
      });
     }catch(e){
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
        companyId: json['companyId'],
        latestSheetVisited: json['latest_sheet_visited'],
        bookTypeId: json['book_typeId'],
        bookTypeName: json['book_type_name'],
        bookType:
            json['book_typeId'] == 1 ? BookType.purchases : BookType.sales,
        updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
        createdAt: DateTime.tryParse(json['created_at'] ?? ''));
  }
}
