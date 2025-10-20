import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:pdf/widgets.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uuid/uuid.dart';

class Import {
  String id;
  String companyId;
  double cif;
  String declarationNumber;
  String receiptNumber;
  String invoiceNumber;
  double tax;
  double encumbrance;
  double selectiveTax;
  double fines;
  double surcharges;
  double dgaServiceFee;
  num otherConcepts;
  double total;
  DateTime paymentDate;
  DateTime invoiceDate;
  Import(
      {required this.id,
      required this.companyId,
      required this.cif,
      required this.declarationNumber,
      required this.receiptNumber,
      required this.invoiceNumber,
      required this.tax,
      required this.encumbrance,
      required this.selectiveTax,
      required this.fines,
      required this.surcharges,
      required this.dgaServiceFee,
      required this.otherConcepts,
      required this.total,
      required this.paymentDate,
      required this.invoiceDate});

  static Future<Map<String, dynamic>> get(
      {required Company company,
      required DateTime startDate,
      required DateTime endDate}) async {
    try {
      var whereContext =
          '''where "companyId" = '${company.id}' and to_char("paymentDate"::date,'yyyy-mm-dd') between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''';

      var rs = await connection.runTx((c) async {
        var result = await c.mappedResultsQuery(
            ''' select * from public."Import" $whereContext order by "paymentDate"''');

        var results = result.map((e) => Import.fromMap(e['Import']!)).toList();

        if (Platform.isWindows) {
          await c.query('''SET lc_monetary = 'es_US';''');
        } else {}

        var data = await c.mappedResultsQuery('''
         select 
         "declarationNumber" AS "NUMERO DE DECLARACION", 
         to_char("paymentDate"::date,'dd/mm/yyyy')::text AS "FECHA DE PAGO", 
         "cif"::money::text AS "CIF", 
         "tax"::money::text AS "ITBIS", 
         encumbrance::money::text AS "GRAVAMEN",
         "selectiveTax"::money::text AS "IMPUESTOS SELECTIVOS",
         fines::money::text AS "MULTAS",
         surcharges::money::text AS "RECARGOS",
         "dgaServiceFee"::money::text AS "TASA DE SERVICIO DGA",
         "otherConcepts"::money::text AS "OTROS CONCEPTO",
         total::money::text AS "TOTAL"
         from public."Import" $whereContext
         UNION 
         ALL
         select 'TOTAL GENERAL', null, sum("cif")::money::text, 
         sum("tax")::money::text, 
         sum(encumbrance)::money::text,
         sum("selectiveTax")::money::text,
         sum(fines)::money::text,
         sum(surcharges)::money::text,
         sum("dgaServiceFee")::money::text,
         sum("otherConcepts")::money::text,
         sum(total)::money::text 
         from public."Import" $whereContext
      ''');
        return [results, data];
      });

      var list = (rs[1] as List<Map<String, Map<String, dynamic>>>)
          .map((e) => e['']!)
          .toList();

      var cols = list[0].keys;

      var pdf = Document();

      var rows = List.generate(list.length, (index) {
        var item = list[index];
        return TableRow(
            children: item.values
                .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text((e ?? '').toString(),
                        style: const TextStyle(fontSize: 8))))
                .toList());
      });

      pdf.addPage(MultiPage(
          margin: const EdgeInsets.all(20),
          orientation: PageOrientation.landscape,
          build: (ctx) {
            return [
              Text(
                  '${company.name} - ${startDate.format(payload: 'DD/MM/YYYY')} - ${endDate.format(payload: 'DD/MM/YYYY')}',
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
              SizedBox(height: 16),
              Table(columnWidths: {
                0: const FixedColumnWidth(100)
              }, children: [
                TableRow(
                    children: cols
                        .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(e,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))))
                        .toList()),
                ...rows
              ])
            ];
          }));

      return {'result': rs[0], 'pdfBytes': await pdf.save()};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> create() async {
    try {
      await connection.execute('''
          INSERT INTO public."Import"(
          id,"companyId", cif, "declarationNumber", "receiptNumber", "invoiceNumber", tax, encumbrance, "selectiveTax", fines, surcharges, "dgaServiceFee", "otherConcepts", total, "paymentDate", "invoiceDate")
          VALUES ('$id','$companyId', $cif, '$declarationNumber', '$receiptNumber', '$invoiceNumber', $tax, $encumbrance, $selectiveTax, $fines, $surcharges, $dgaServiceFee, $otherConcepts, $total, '${paymentDate.format(payload: 'YYYY-MM-DD HH:mm:ss')}','${invoiceDate.format(payload: 'YYYY-MM-DD HH:mm:ss')}');
       ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update() async {
    try {
      await connection.execute('''
           UPDATE public."Import"
           SET cif=$cif, "declarationNumber"='$declarationNumber', "receiptNumber"='$receiptNumber', 
          "invoiceNumber"='$invoiceNumber',
           tax=$tax,
           encumbrance=$encumbrance,
          "selectiveTax"=$selectiveTax, fines=$fines, surcharges=$surcharges, "dgaServiceFee"=$dgaServiceFee,
          "otherConcepts"=$otherConcepts, 
           total=$total, 
          "paymentDate"='${paymentDate.format(payload: 'YYYY-MM-DD HH:mm:ss')}',
          "invoiceDate"='${invoiceDate.format(payload: 'YYYY-MM-DD HH:mm:ss')}'
           WHERE "id" = '$id';
      ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      await connection
          .execute(''' delete from public."Import" where "id" = '$id' ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfExist(DateTime startDate, DateTime endDate) async {
    try {
      var res = await connection.query(
          ''' select * from public."Import" where "paymentDate" between '${startDate.toIso8601String()}' and '${endDate.toIso8601String()}' and  "receiptNumber" like '%$receiptNumber%' ''');

      if (res.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<DateTime?> importFromDgii(Company company) async {
    try {
      var data = await Clipboard.getData('text/plain');

      if (data != null && data.text!.isEmpty) {
        throw 'EL PORTAPAPELES ESTA VACIO';
      }

      if (!data!.text!.contains('IC01') || data.text!.contains('<')) {
        throw 'NO ES UNA FORMATO DE IMPORTACION VALIDO';
      }

      var newArr = data.text?.trim().split('\n');

      DateTime? payDateTime;

      final len = newArr?.length;

      if (newArr != null) {
        for (int i = 0; i < len!; ++i) {
          var item = newArr[i];

          if (item.contains('Fecha')) {
            continue;
          }
          var id = const Uuid().v1();
          var list = item.split('\t');

          var payD = list[1];
          var invD = list[4];

          var x = payD.split(' ');
          var x1 = x[0].split('/');
          var m = int.parse(x1[0]);
          var d = int.parse(x1[1]);
          var y = int.parse(x1[2]);
          var x2 = x[1].split(':');
          var h = int.parse(x2[0]);
          var mi = int.parse(x2[1]);

          payDateTime = DateTime(y, m, d, h, mi);

          var o = invD.split(' ');
          var o1 = o[0].split('/');
          var om = int.parse(o1[0]);
          var od = int.parse(o1[1]);
          var oy = int.parse(o1[2]);
          var o2 = o[1].split(':');
          var oh = int.parse(o2[0]);
          var omi = int.parse(o2[1]);

          var invoiceDateTime = DateTime(oy, om, od, oh, omi);

          var import = Import(
              id: id,
              companyId: company.id!,
              cif: 0,
              declarationNumber: list[0],
              receiptNumber: list[2],
              invoiceNumber: list[3],
              tax: double.parse(list[5].replaceAll(',', '')),
              encumbrance: double.parse(list[6].replaceAll(',', '')),
              selectiveTax: double.parse(list[7].replaceAll(',', '')),
              fines: double.parse(list[8].replaceAll(',', '')),
              surcharges: double.parse(list[9].replaceAll(',', '')),
              dgaServiceFee: double.parse(list[10].replaceAll(',', '')),
              otherConcepts: double.parse(list[11].replaceAll(',', '')),
              total: double.parse(list[12].replaceAll(',', '')),
              paymentDate: payDateTime,
              invoiceDate: invoiceDateTime);

          if (!(await import.checkIfExist(
              payDateTime.startOfMonth(), payDateTime.endOfMonth()))) {
            await import.create();
            print('created');
          } else {
            print('exist');
          }
        }
      }
      return payDateTime;
    } catch (e) {
      rethrow;
    } finally {
      await Clipboard.setData(ClipboardData(text: ''));
    }
  }

  Map<String, dynamic> toDisplay() {
    return {
      'NUMERO DE DECLARACION': declarationNumber,
      'FECHA DE PAGO': paymentDate.format(payload: 'DD/MM/YYYY HH:mm:ss'),
      'NUMERO DE RECIBO': receiptNumber,
      'NUMERO DE FACTURA': invoiceNumber,
      'FECHA DE FACTURA': invoiceDate.format(payload: 'DD/MM/YYYY HH:mm:ss'),
      'CIF': cif.toStringAsFixed(2),
      'ITBIS': tax.toStringAsFixed(2),
      'GRAVAMEN': encumbrance.toStringAsFixed(2),
      'IMPUESTOS SELECTIVOS': selectiveTax.toStringAsFixed(2),
      'MULTAS': fines.toStringAsFixed(2),
      'RECARGOS': surcharges.toStringAsFixed(2),
      'TASA DE SERVICIO DGA': dgaServiceFee.toStringAsFixed(2),
      'OTROS CONCEPTO': otherConcepts.toStringAsFixed(2),
      'TOTAL': total.toStringAsFixed(2)
    };
  }

  Import copyWith({
    String? id,
    String? companyId,
    double? cif,
    String? declarationNumber,
    String? receiptNumber,
    String? invoiceNumber,
    double? tax,
    double? encumbrance,
    double? selectiveTax,
    double? fines,
    double? surcharges,
    double? dgaServiceFee,
    num? otherConcepts,
    double? total,
    DateTime? paymentDate,
    DateTime? invoiceDate,
  }) {
    return Import(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      cif: cif ?? this.cif,
      declarationNumber: declarationNumber ?? this.declarationNumber,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      tax: tax ?? this.tax,
      encumbrance: encumbrance ?? this.encumbrance,
      selectiveTax: selectiveTax ?? this.selectiveTax,
      fines: fines ?? this.fines,
      surcharges: surcharges ?? this.surcharges,
      dgaServiceFee: dgaServiceFee ?? this.dgaServiceFee,
      otherConcepts: otherConcepts ?? this.otherConcepts,
      total: total ?? this.total,
      paymentDate: paymentDate ?? this.paymentDate,
      invoiceDate: invoiceDate ?? this.invoiceDate,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'companyId': companyId});
    result.addAll({'cif': cif});
    result.addAll({'declarationNumber': declarationNumber});
    result.addAll({'receiptNumber': receiptNumber});
    result.addAll({'invoiceNumber': invoiceNumber});
    result.addAll({'tax': tax});
    result.addAll({'encumbrance': encumbrance});
    result.addAll({'selectiveTax': selectiveTax});
    result.addAll({'fines': fines});
    result.addAll({'surcharges': surcharges});
    result.addAll({'dgaServiceFee': dgaServiceFee});
    result.addAll({'otherConcepts': otherConcepts});
    result.addAll({'total': total});
    result.addAll({'paymentDate': paymentDate.millisecondsSinceEpoch});
    result.addAll({'invoiceDate': invoiceDate.millisecondsSinceEpoch});

    return result;
  }

  factory Import.fromMap(Map<String, dynamic> map) {
    return Import(
      id: map['id'] ?? '',
      companyId: map['companyId'] ?? '',
      cif: double.tryParse(map['cif']) ?? 0.0,
      declarationNumber: map['declarationNumber'] ?? '',
      receiptNumber: map['receiptNumber'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      tax: double.tryParse(map['tax']) ?? 0.0,
      encumbrance: double.tryParse(map['encumbrance']) ?? 0.0,
      selectiveTax: double.tryParse(map['selectiveTax']) ?? 0.0,
      fines: double.tryParse(map['fines']) ?? 0.0,
      surcharges: double.tryParse(map['surcharges']) ?? 0.0,
      dgaServiceFee: double.tryParse(map['dgaServiceFee']) ?? 0.0,
      otherConcepts: num.tryParse(map['otherConcepts']) ?? 0,
      total: double.tryParse(map['total']) ?? 0.0,
      paymentDate: map['paymentDate'],
      invoiceDate: map['invoiceDate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Import.fromJson(String source) => Import.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Import(id: $id, companyId: $companyId, cif: $cif, declarationNumber: $declarationNumber, receiptNumber: $receiptNumber, invoiceNumber: $invoiceNumber, tax: $tax, encumbrance: $encumbrance, selectiveTax: $selectiveTax, fines: $fines, surcharges: $surcharges, dgaServiceFee: $dgaServiceFee, otherConcepts: $otherConcepts, total: $total, paymentDate: $paymentDate, invoiceDate: $invoiceDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Import &&
        other.id == id &&
        other.companyId == companyId &&
        other.cif == cif &&
        other.declarationNumber == declarationNumber &&
        other.receiptNumber == receiptNumber &&
        other.invoiceNumber == invoiceNumber &&
        other.tax == tax &&
        other.encumbrance == encumbrance &&
        other.selectiveTax == selectiveTax &&
        other.fines == fines &&
        other.surcharges == surcharges &&
        other.dgaServiceFee == dgaServiceFee &&
        other.otherConcepts == otherConcepts &&
        other.total == total &&
        other.paymentDate == paymentDate &&
        other.invoiceDate == invoiceDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        cif.hashCode ^
        declarationNumber.hashCode ^
        receiptNumber.hashCode ^
        invoiceNumber.hashCode ^
        tax.hashCode ^
        encumbrance.hashCode ^
        selectiveTax.hashCode ^
        fines.hashCode ^
        surcharges.hashCode ^
        dgaServiceFee.hashCode ^
        otherConcepts.hashCode ^
        total.hashCode ^
        paymentDate.hashCode ^
        invoiceDate.hashCode;
  }
}
