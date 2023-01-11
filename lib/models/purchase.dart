import 'package:uresaxapp/apis/http-client.dart';

class Purchase {
  String? id;
  String? invoiceRnc;
  int? invoiceTypeId;
  int? invoiceBankingId;
  int? invoicePaymentMethodId;
  int? invoiceConceptId;
  String? invoiceNcf;
  String? invoiceNcfModifed;
  double? invoiceItbis18;
  double? invoiceItbis16;
  double? invoiceTotalServ;
  double? invoiceTotalBin;
  String? invoiceCk;
  String? invoiceNcfDate;
  String? invoiceNcfDay;
  String? invoiceSheetId;
  String? invoiceBookId;
  String? invoiceCompanyId;

  Purchase(
      {
      this.id,
      this.invoiceRnc,
      this.invoiceConceptId,
      this.invoiceTypeId,
      this.invoicePaymentMethodId,
      this.invoiceNcf,
      this.invoiceNcfDate,
      this.invoiceNcfDay,
      this.invoiceSheetId,
      this.invoiceBookId,
      this.invoiceCompanyId,
      this.invoiceItbis18,
      this.invoiceItbis16,
      this.invoiceTotalServ,
      this.invoiceTotalBin,
      this.invoiceNcfModifed,
      this.invoiceBankingId,
      this.invoiceCk});

  Map<String, dynamic> toMap() {
    return {
      'invoice_rnc': invoiceRnc,
      'invoice_conceptId':invoiceConceptId,
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

  Future<void> delete()async{
     try{
       await httpClient.delete('/purchases/$id');
     }catch(e){
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
