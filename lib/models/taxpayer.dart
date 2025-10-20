import 'package:uresaxapp/apis/connection.dart';

class TaxPayer {
  String? taxPayerId;
  String? taxPayerCompanyName;
  String? taxPayerTradeName;
  String? taxPayerAbout;
  DateTime? createdAt;
  String? taxPayerState;
  String? taxPayerPaymentStatus;

  TaxPayer(
      {this.taxPayerId,
      this.taxPayerCompanyName,
      this.taxPayerTradeName,
      this.taxPayerAbout,
      this.createdAt,
      this.taxPayerState,
      this.taxPayerPaymentStatus});

  static Future<List<TaxPayer>> get({String words = ''}) async {
    try {
      var res = await connection.mappedResultsQuery(
          ''' select * from public."TaxPayer" where "tax_payerId" like '%$words%' or "tax_payer_company_name" like '%$words%' limit 15; ''');
      return res.map((e) => TaxPayer.fromJson(e['TaxPayer']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TaxPayer> create() async {
    try {
      var res = await connection.runTx((c) async {
      await c.mappedResultsQuery('''
           INSERT INTO public."TaxPayer"(
	         "tax_payerId", tax_payer_company_name, tax_payer_trade_name, tax_payer_about, col1, col2, col3, col4, created_at, tax_payer_state, tax_payer_payment_status)
	         VALUES ('$taxPayerId', '$taxPayerCompanyName', '$taxPayerTradeName', '', '', '', '', '', '${createdAt.toString()}', 'ACTIVO', 'NORMAL');
      ''');
        var res = await c.mappedResultsQuery(
            ''' select * from public."TaxPayer" where "tax_payerId" = '$taxPayerId'; ''');
        return res;
      });

      return TaxPayer.fromJson(res.first['TaxPayer']!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete()async{
     try{
       await connection.execute(''' delete from public."TaxPayer" where "tax_payerId" = '$taxPayerId'; ''');
     }catch(e){
      rethrow;
     }
  }

  TaxPayer.fromJson(Map<String, dynamic> json) {
    taxPayerId = json['tax_payerId'];
    taxPayerCompanyName = json['tax_payer_company_name'];
    taxPayerTradeName = json['tax_payer_trade_name'];
    taxPayerAbout = json['tax_payer_about'];
    createdAt = DateTime.tryParse(json['created_at'] ?? 'x');
    taxPayerState = json['tax_payer_state'];
    taxPayerPaymentStatus = json['tax_payer_payment_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tax_payerId'] = taxPayerId;
    data['tax_payer_company_name'] = taxPayerCompanyName;
    data['tax_payer_trade_name'] = taxPayerTradeName;
    data['tax_payer_about'] = taxPayerAbout;
    data['created_at'] = createdAt.toString();
    data['tax_payer_state'] = taxPayerState;
    data['tax_payer_payment_status'] = taxPayerPaymentStatus;
    return data;
  }
}
