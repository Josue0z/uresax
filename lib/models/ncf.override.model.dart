// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/apis/connection.dart';

class NcfOverrideModel {
  String id;
  String ncf;
  String typeOfOverride;
  String companyId;
  String authorId;
  String? typeOfOverrideName;
  String? authorName;
  String? ncfDateDisplay;
  int ncfTypeId;
  DateTime ncfDate;
  DateTime? createdAt;
  NcfOverrideModel({
    required this.id,
    required this.ncf,
    required this.typeOfOverride,
    required this.companyId,
    required this.authorId,
    this.typeOfOverrideName,
    this.authorName,
    this.ncfDateDisplay,
    required this.ncfTypeId,
    required this.ncfDate,
    this.createdAt,
  });

  Future<bool> create() async {
    try {
      await connection.mappedResultsQuery('''
             insert into 
             public."TableOfOverriddenNcfs"(id, ncf, "typeOfOverride","companyId", "authorId", "ncfDate", "ncfTypeId")
             values('$id','$ncf','$typeOfOverride', '$companyId', '$authorId','${ncfDate.format(payload: 'YYYY-MM-DD')}',$ncfTypeId)
          ''');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> update() async {
    try {
      await connection.mappedResultsQuery('''
             UPDATE public."TableOfOverriddenNcfs"
             SET ncf= '$ncf', "typeOfOverride"= '$typeOfOverride', "companyId"= '$companyId', "authorId"= '$authorId', "ncfDate"= '${ncfDate.format(payload: 'YYYY-MM-DD')}', "ncfTypeId"= $ncfTypeId
             WHERE id = '$id'
          ''');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  NcfOverrideModel copyWith({
    String? id,
    String? ncf,
    String? typeOfOverride,
    String? companyId,
    String? authorId,
    String? typeOfOverrideName,
    String? authorName,
    String? ncfDateDisplay,
    int? ncfTypeId,
    DateTime? ncfDate,
    DateTime? createdAt,
  }) {
    return NcfOverrideModel(
      id: id ?? this.id,
      ncf: ncf ?? this.ncf,
      typeOfOverride: typeOfOverride ?? this.typeOfOverride,
      companyId: companyId ?? this.companyId,
      authorId: authorId ?? this.authorId,
      typeOfOverrideName: typeOfOverrideName ?? this.typeOfOverrideName,
      authorName: authorName ?? this.authorName,
      ncfTypeId: ncfTypeId ?? this.ncfTypeId,
      ncfDateDisplay: ncfDateDisplay ?? this.ncfDateDisplay,
      ncfDate: ncfDate ?? this.ncfDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Future<List<NcfOverrideModel>> get(
      {required String companyId,
      required DateTime startDate,
      required DateTime endDate,
      String searchWord = '',
      bool searchMode = false}) async {
    try {
      var searchContext = '';

      if (searchMode && searchWord != '') {
        searchContext =
            ''' and (lower("authorName") like lower('%$searchWord%') or "ncf" like '%$searchWord%' or "typeOfOverrideName" like '%$searchWord%') ''';
      }
      var res = await connection.mappedResultsQuery('''
          select * from public."TableOfOverridenNcfsDetails"
          where "companyId" = '$companyId' $searchContext
          and "ncfDate" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' order by "ncfDate";''');

      return res.map((e) => NcfOverrideModel.fromMap(e['']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getListPeriods(
      {String id = '', String search = ''}) async {
    try {
      var searchContext = '';
      if (search != '') {
        searchContext =
            ''' and to_char("ncfDate",'yyyymm') like '%$search%' ''';
      }
      var result = await connection.mappedResultsQuery('''
            SELECT to_char("ncfDate",'yyyy-mm')
            AS date_label
            FROM public."TableOfOverriddenNcfs" 
            WHERE "companyId" = '$id' $searchContext
            GROUP BY to_char("ncfDate",'yyyy-mm')
            ORDER BY to_char("ncfDate",'yyyy-mm') DESC
        ''');

      return result.map((e) => e['']!).toList();
    } catch (e) {
      rethrow;
    }
  }

  toDisplay() {
    return {
      'EDITOR': authorName,
      'NCF': ncf,
      'FECHA DE COMPROBANTE': ncfDate.format(payload: 'DD/MM/YYYY'),
      'TIPO DE ANULACION': typeOfOverrideName,
      'CREADO EL': createdAt?.format(payload: 'DD/MM/YYYY HH:mm:ss')
    };
  }

  to608() {
    return {
      'ncf': ncf,
      'date': ncfDateDisplay,
      'typeOfOverride': typeOfOverride
    };
  }

  Future delete() async {
    try {
      await connection.execute(
          ''' delete from public."TableOfOverriddenNcfs" where "id" = '$id' ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> move(String newCompanyId) async {
    try {
      await connection.mappedResultsQuery(
          ''' update public."TableOfOverriddenNcfs" set "companyId" = '$newCompanyId' where "id"  = '$id'; ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfExists(
      {required String companyId,
      required DateTime startDate,
      required DateTime endDate}) async {
    try {
      var res = await connection.mappedResultsQuery(
          '''select * from public."TableOfOverriddenNcfs" where "companyId" = '$companyId' and "ncfDate" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' and "ncf" = '$ncf';''');
      if (res.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'ncf': ncf,
      'typeOfOverride': typeOfOverride,
      'companyId': companyId,
      'authorId': authorId,
      'typeOfOverrideName': typeOfOverrideName,
      'authorName': authorName,
      'ncfDateDisplay': ncfDateDisplay,
      'ncfTypeId': ncfTypeId,
      'ncfDate': ncfDate.toString(),
      'createdAt': createdAt?.toString(),
    };
  }

  factory NcfOverrideModel.fromMap(Map<String, dynamic> map) {
    return NcfOverrideModel(
      id: map['id'] as String,
      ncf: map['ncf'] as String,
      typeOfOverride: map['typeOfOverride'] as String,
      companyId: map['companyId'] as String,
      authorId: map['authorId'] as String,
      typeOfOverrideName: map['typeOfOverrideName'] as String?,
      authorName: map['authorName'] as String?,
      ncfDateDisplay: map['ncfDateDisplay'] as String?,
      ncfTypeId: map['ncfTypeId'],
      ncfDate: map['ncfDate'] is String
          ? DateTime.parse(map['ncfDate'])
          : map['ncfDate'],
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NcfOverrideModel.fromJson(String source) =>
      NcfOverrideModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NcfOverrideModel(id: $id, ncf: $ncf, typeOfOverride: $typeOfOverride, companyId: $companyId, authorId: $authorId, typeOfOverrideName: $typeOfOverrideName, authorName: $authorName, ncfDateDisplay: $ncfDateDisplay, ncfTypeId: $ncfTypeId, ncfDate: $ncfDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant NcfOverrideModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.ncf == ncf &&
        other.typeOfOverride == typeOfOverride &&
        other.companyId == companyId &&
        other.authorId == authorId &&
        other.typeOfOverrideName == typeOfOverrideName &&
        other.authorName == authorName &&
        other.ncfDateDisplay == ncfDateDisplay &&
        other.ncfDate == ncfDate &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ncf.hashCode ^
        typeOfOverride.hashCode ^
        companyId.hashCode ^
        authorId.hashCode ^
        typeOfOverrideName.hashCode ^
        authorName.hashCode ^
        ncfDateDisplay.hashCode ^
        ncfDate.hashCode ^
        createdAt.hashCode;
  }
}
