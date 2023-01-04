import 'package:uresaxapp/apis/http-client.dart';

class Purchase {
  String invoiceRnc;
  int invoiceTypeId;
  int? invoiceBankingId;
  int invoicePaymentMethodId;
  String? invoiceNcf;
  String? invoiceNcfModifed;
  double? invoiceItbis18;
  double? invoiceItbis16;
  double? invoiceTotalServ;
  double? invoiceTotalBin;
  String? invoiceCk;
  String invoiceNcfDate;
  String invoiceNcfDay;
  String invoiceSheetId;
  String invoiceBookId;
  String invoiceCompanyId;

  Purchase(
      {required this.invoiceRnc,
      required this.invoiceTypeId,
      required this.invoicePaymentMethodId,
      required this.invoiceNcf,
      required this.invoiceNcfDate,
      required this.invoiceNcfDay,
      required this.invoiceSheetId,
      required this.invoiceBookId,
      required this.invoiceCompanyId,
      required this.invoiceItbis18,
      required this.invoiceItbis16,
      required this.invoiceTotalServ,
      required this.invoiceTotalBin,
      required this.invoiceNcfModifed,
      required this.invoiceBankingId,
      required this.invoiceCk});

  Map<String, dynamic> toMap() {
    return {
      'invoice_rnc': invoiceRnc,
      'invoice_typeId': invoiceTypeId,
      'invoice_bankingId': invoiceBankingId,
      'invoice_payment_methodId': invoicePaymentMethodId,
      'invoice_ncf': invoiceNcf,
      'invoice_ncf_modifed': invoiceNcfModifed,
      'invoice_itbis_16': invoiceItbis16 ?? 0.00,
      'invoice_itbis_18': invoiceItbis18 ?? 0.00,
      'invoice_total_serv': invoiceTotalServ ?? 0.00,
      'invoice_total_bin': invoiceTotalBin ?? 0.00,
      'invoice_ck': invoiceCk,
      'invoice_ncf_date': invoiceNcfDate,
      'invoice_ncf_day': invoiceNcfDay,
      'invoice_sheetId': invoiceSheetId,
      'invoice_bookId': invoiceBookId,
      'invoice_companyId': invoiceCompanyId
    };
  }

  Future<bool> create() async {
    try {
      await httpClient.post('/purchases', data: toMap());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getPurchases(
      {String sheetId = ''}) async {
    try {
      var results = await httpClient.get('/purchases?sheetId=$sheetId');
      return (results.data as List)
          .map((e) => e)
          .toList()
          .cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }
}
