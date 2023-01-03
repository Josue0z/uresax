import 'package:dio/dio.dart';
import 'package:uresaxapp/apis/http-client.dart';

class Company {
  String? id;
  String? name;
  String? rnc;
  DateTime? updatedAt;
  DateTime createdAt;
  Company(
      {required this.id,
      required this.name,
      required this.rnc,
      this.updatedAt,
      required this.createdAt});

  static Future<List<Company>> getCompanies() async {
    try {
      var response = await httpClient.get('/companies');
      return (response.data as List)
          .map((map) => Company.fromJson(map))
          .toList()
          .cast<Company>();
    } catch (e) {
      rethrow;
    }
  }

  Future<Company> create() async {
    try {
      var response =
          await httpClient.post('/companies', data: {'company_rnc': rnc});
      return Company.fromJson(response.data);
    } on DioError catch (e) {
      if (e.error == 'Http status error [422]') {
        throw CompanyExists();
      }
      throw '';
    }
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
        id: json['id'],
        name: json['company_name'],
        rnc: json['company_rnc'],
        updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now());
  }

  toJson() {
    return {
      'id': id,
      'company_name': name,
      'company_rnc': rnc,
      'updated_at': updatedAt?.toUtc().toString(),
      'created_at': createdAt.toUtc().toString()
    };
  }
}

class CompanyExists implements Exception {
  CompanyExists({String? message});
}
