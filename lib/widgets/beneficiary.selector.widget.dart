import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/beneficiary.dart';
import 'package:uresaxapp/pages/beneficiaries.page.dart';
import 'package:uresaxapp/pages/company_details.dart';

class BeneficiarySelectorWidget extends StatefulWidget {
  final CompanyDetailsPage companyDetailsPage;

  int? currentBeneficiaryId;

  Beneficiary? currentBeneficiary;

  List<Beneficiary> beneficiaries = [];

  Function(Beneficiary?) onSelected;

  BeneficiarySelectorWidget(
      {super.key,
      this.currentBeneficiary,
      this.currentBeneficiaryId,
      this.beneficiaries = const [],
      required this.onSelected,
      required this.companyDetailsPage});

  @override
  State<BeneficiarySelectorWidget> createState() =>
      _BeneficiarySelectorWidgetState();
}

class _BeneficiarySelectorWidgetState extends State<BeneficiarySelectorWidget> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          var res = await Get.to(() => BeneficiariesPage(isEditionMode: false),
              preventDuplicates: false);

          if (res != 'closed') {
            widget.currentBeneficiary = res;
            widget.onSelected(widget.currentBeneficiary);
            setState(() {});
          }
        },
        child: Container(
          height: 60,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black26)),
          child: Row(
            children: [
              Expanded(
                  child: Text(widget.currentBeneficiary?.name ?? 'BENEFICIARIO',
                      style: const TextStyle(
                          fontSize: 16, overflow: TextOverflow.ellipsis))),
              const Icon(Icons.arrow_drop_down)
            ],
          ),
        ));
  }
}
