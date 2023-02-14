import 'package:uuid/uuid.dart';
import 'package:uresaxapp/apis/connection.dart';

class Company {
  String? id;
  String? name;
  String? rnc;
  DateTime? updatedAt;
  DateTime? createdAt;
  Company({this.id, this.name, this.rnc, this.updatedAt, this.createdAt});

  static Future<List<Company>> all() async {
    try{
     var results = await connection
      .mappedResultsQuery('''select * from public."CompanyDetails";''');
      return results.map((row) => Company.fromJson(row['']!)).toList();
    }catch(e){
       rethrow;
    }
  }

  Future<Company> create() async {
     try {
      var id = const Uuid().v4();
      await connection.query(
          '''insert into public."Company"("id","company_rnc") values('$id','$rnc');''');
      var results = await connection.mappedResultsQuery(
          '''select * from public."CompanyDetails" where "id" = '$id';''');
      return Company.fromJson(results.first['']!);
    } catch (e) {
      rethrow;
    }
  }


   Future<void> delete()async{
     try{
      await connection.runTx((c) async {
      await c.query('''DELETE FROM public."Purchase" WHERE "invoice_companyId" = '$id';''');
      await c.query('''DELETE FROM public."Sheet" WHERE "companyId" = '$id';''');
      await c.query('''DELETE FROM public."Book" WHERE "companyId" = '$id';''');
      await c.query('''DELETE FROM public."Company" WHERE "id" = '$id';''');
      });
     }catch(e){
      rethrow;
     }
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
        id: json['id'],
        name: json['company_name'],
        rnc: json['company_rnc'],
        updatedAt: json['updated_at'],
        createdAt: json['created_at']);
  }

  toJson() {
    return {
      'id': id,
      'company_name': name,
      'company_rnc': rnc,
      'updated_at': updatedAt?.toUtc().toString(),
      'created_at': createdAt?.toUtc().toString()
    };
  }
}

