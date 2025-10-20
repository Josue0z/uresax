import 'dart:convert';

import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uuid/uuid.dart';

import 'package:uresaxapp/apis/connection.dart';

class Check {
  String? id;
  String? companyId;
  String? checkNumber;
  String? beneficiaryName;
  String? bankingName;
  String? brand;
  int? bankingId;
  int? beneficiaryId;
  int? bankingEntityId;
  String? bankingEntityName;
  DateTime? checkDate;
  DateTime? periodDate;
  double? total;
  Check(
      {this.id,
      this.companyId,
      this.checkNumber,
      this.beneficiaryName,
      this.bankingName,
      this.bankingId,
      this.bankingEntityId,
      this.beneficiaryId,
      this.checkDate,
      this.periodDate,
      this.brand,
      this.total,
      this.bankingEntityName});

  String? get fullName {
    if (brand == null && checkNumber == null && beneficiaryName == null)return null;
    return '$brand/$bankingEntityName/$checkNumber - $beneficiaryName';
  }

  Future<void> create() async {
    try {
      await connection.mappedResultsQuery(
          ''' insert into public."Check"(id, "companyId", "bankingId","bankingEntityId", "checkNumber", "beneficiaryId", "checkDate", "periodDate", total) values('${const Uuid().v1()}', '$companyId', $bankingId,$bankingEntityId, '$checkNumber', $beneficiaryId,'${checkDate!.format(payload: 'YYYY-MM-DD')}', '${periodDate!.format(payload: 'YYYY-MM-DD')}', $total) ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update() async {
    try {
      await connection.mappedResultsQuery(
          '''update public."Check" set "bankingId" = $bankingId, "bankingEntityId" = $bankingEntityId, "checkNumber" = '$checkNumber', "beneficiaryId" = $beneficiaryId, "checkDate" = '${checkDate!.format(payload: 'YYYY-MM-DD')}', "periodDate" = '${periodDate!.format(payload: 'YYYY-MM-DD')}', total = $total where id = '$id' ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      await connection
          .execute(''' delete from public."Check" where id = '$id' ''');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Check>> get(
      {
      required Company company,
      String words = '',
      bool searchMode = false,
      DateTime? startDate,
      DateTime? endDate
      }) async {
    try {
      var searchContext = '';
      var rangeDates = '';

      if (searchMode && words.isNotEmpty) {
        searchContext =
            ''' and ("checkDateInfo" like '%$words%' or "checkNumber" like '%$words%' or upper("bankingName") like '%$words%' or upper("beneficiaryName") like '%$words%') or total::text like '%$words%' or "bankingEntityName" like '%$words%' ''';
      }
      /*if(startDate != null && endDate != null){
         rangeDates = ''' and "periodDate" between '${startDate.format(payload:'YYYY-MM-DD')}' and '${endDate.format(payload:'YYYY-MM-DD')}' ''';
      }*/
  
      var results = await connection.mappedResultsQuery(
          ''' select * from public."CheckView" where "companyId" = '${company.id}' $searchContext $rangeDates order by "checkDate", "bankingName" ''');
      return results.map((e) => Check.fromMap(e['']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Check> find(String? id) async {
    try {
      var result = await connection.mappedResultsQuery(
          ''' select * from public."CheckView" where id = '$id' ''');
      return Check.fromMap(result.first['']!);
    } catch (e) {
      rethrow;
    }
  }

  Check copyWith({
    String? id,
    String? companyId,
    String? checkNumber,
    String? beneficiaryName,
    String? bankingName,
    int? bankingId,
    int? beneficiaryId,
    DateTime? checkDate,
    DateTime? periodDate,
    double? total,
  }) {
    return Check(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      checkNumber: checkNumber ?? this.checkNumber,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      bankingName: bankingName ?? this.bankingName,
      bankingId: bankingId ?? this.bankingId,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      checkDate: checkDate ?? this.checkDate,
      periodDate: periodDate ?? this.periodDate,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    if (companyId != null) {
      result.addAll({'companyId': companyId});
    }
    if (checkNumber != null) {
      result.addAll({'checkNumber': checkNumber});
    }
    if (beneficiaryName != null) {
      result.addAll({'beneficiaryName': beneficiaryName});
    }
    if (bankingName != null) {
      result.addAll({'bankingName': bankingName});
    }
    if (bankingId != null) {
      result.addAll({'bankingId': bankingId});
    }
    if (beneficiaryId != null) {
      result.addAll({'beneficiaryId': beneficiaryId});
    }
    if (checkDate != null) {
      result.addAll({'checkDate': checkDate!.millisecondsSinceEpoch});
    }
    if (periodDate != null) {
      result.addAll({'periodDate': periodDate!.millisecondsSinceEpoch});
    }
    if (total != null) {
      result.addAll({'total': total});
    }

    return result;
  }

  factory Check.fromMap(Map<String, dynamic> map) {
    return Check(
      id: map['id'],
      companyId: map['companyId'],
      checkNumber: map['checkNumber'],
      beneficiaryName: map['beneficiaryName'],
      bankingName: map['bankingName'],
      bankingId: map['bankingId']?.toInt(),
      bankingEntityId: map['bankingEntityId'],
      bankingEntityName: map['bankingEntityName'],
      beneficiaryId: map['beneficiaryId']?.toInt(),
      checkDate: map['checkDate'],
      periodDate: map['periodDate'],
      brand: map['brand'],
      total: double.tryParse(map['total']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Check.fromJson(String source) => Check.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Check(id: $id, companyId: $companyId, checkNumber: $checkNumber, beneficiaryName: $beneficiaryName, bankingName: $bankingName, bankingId: $bankingId, beneficiaryId: $beneficiaryId, checkDate: $checkDate, periodDate: $periodDate, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Check &&
        other.id == id &&
        other.companyId == companyId &&
        other.checkNumber == checkNumber &&
        other.beneficiaryName == beneficiaryName &&
        other.bankingName == bankingName &&
        other.bankingId == bankingId &&
        other.beneficiaryId == beneficiaryId &&
        other.checkDate == checkDate &&
        other.periodDate == periodDate &&
        other.total == total;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        checkNumber.hashCode ^
        beneficiaryName.hashCode ^
        bankingName.hashCode ^
        bankingId.hashCode ^
        beneficiaryId.hashCode ^
        checkDate.hashCode ^
        periodDate.hashCode ^
        total.hashCode;
  }
}
