// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/checks.controller.dart';
import 'package:uresaxapp/models/banking.dart';
import 'package:uresaxapp/models/bankingEntity.dart';
import 'package:uresaxapp/models/beneficiary.dart';
import 'package:uresaxapp/models/check.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/beneficiary.selector.widget.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/date.selector.widget.dart';

class AddCheckModal extends StatefulWidget {
  final CompanyDetailsPage companyDetailsPage;

  final bool isEditionMode;
  final Check? check;

  bool isEditing;

  AddCheckModal(
      {super.key,
      required this.companyDetailsPage,
      required this.isEditionMode,
      this.check,
      this.isEditing = false});

  @override
  State<AddCheckModal> createState() => _AddCheckModalState();
}

class _AddCheckModalState extends State<AddCheckModal> {
  List<Beneficiary> beneficiaries = [];

  int? currentBankingId;

  int? currentBeneficiaryId;

  Beneficiary? currentBeneficiary;

  bool loading = false;

  List<Banking> bankings = [];

  DateTime? startDate;

  DateTime? checkDate;

  TextEditingController checkNumber = TextEditingController();

  TextEditingController beneficiary = TextEditingController();

  TextEditingController total = TextEditingController();

  StreamController<String> streamController = StreamController();

  final formKey = GlobalKey<FormState>();

  List<BankingEntity> bankingEntities = [];

  int? currentBankingEntityId;

  String get title {
    return !widget.isEditing
        ? 'AÑADIENDO ENTIDAD BANCARIA'
        : 'EDITANDO ENTIDAD BANCARIA';
  }

  String get btnTitle {
    return !widget.isEditing ? 'AÑADIR ENTIDAD' : 'EDITAR ENTIDAD';
  }

  Widget get loadingContainer {
    return const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [CircularProgressIndicator()],
    ));
  }

  init() async {
    loading = true;
    try {
      bankings = [Banking(name: 'BANCO'), ...(await Banking.getBankings())];
      bankingEntities = [
        BankingEntity(name: 'ENTIDAD BANCARIA'),
        ...(await BankingEntity.get())
      ];

      startDate = widget.companyDetailsPage.startDate;
      checkDate = startDate;

      if (widget.isEditing && widget.check != null) {
        currentBeneficiary =
            await Beneficiary.findById(widget.check!.beneficiaryId!);

        currentBeneficiaryId = currentBeneficiary?.id;

        currentBankingEntityId = widget.check?.bankingEntityId;

        currentBankingId = widget.check?.bankingId;
        checkNumber.value =
            TextEditingValue(text: widget.check?.checkNumber ?? '');
        total.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.check?.total?.toStringAsFixed(2) ?? ''));
        startDate = widget.check?.checkDate;
        checkDate = widget.check?.checkDate;
      }

      streamController.add(checkDate!.format(payload: 'DD/MM/YYYY'));
      loading = false;
      setState(() {});
    } catch (e) {
      loading = false;
      setState(() {});
    }
  }

  onSubmit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (currentBeneficiaryId == null) {
          throw 'AGREGA UN BENEFICIARIO';
        }

        var check = Check(
            id: widget.check?.id,
            companyId: widget.companyDetailsPage.company.id,
            checkNumber: checkNumber.text.trim(),
            bankingId: currentBankingId,
            bankingEntityId: currentBankingEntityId,
            beneficiaryId: currentBeneficiaryId,
            checkDate: checkDate,
            total: double.tryParse(total.text.replaceAll(',', '')),
            periodDate: DateTime(widget.companyDetailsPage.startDate.year,
                widget.companyDetailsPage.startDate.month, 1));
        if (!widget.isEditing) {
          await check.create();
        } else {
          await check.update();
        }

        var c = Get.find<ChecksController>();

        var res = await Check.get(company: widget.companyDetailsPage.company);

        if (!widget.isEditionMode) {
          c.checks.value = [Check(), ...res];
        } else {
          c.checks.value = res;
        }

        Get.back();

        if (widget.isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('SE ACTUALIZO LA ENTIDAD BANCARIA')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE INSERTO LA ENTIDAD BANCARIA')));
        }
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      width: 1,
      color: kWindowBorderColor,
      child: Column(
        children: [
          const CustomFrameWidgetDesktop(),
          Expanded(
              child: Dialog(
                  child: SizedBox(
            width: 450,
            child: loading
                ? loadingContainer
                : Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor),
                                ),
                                const Spacer(),
                                IconButton(
                                    onPressed: () => Get.back(),
                                    icon: const Icon(Icons.close))
                              ],
                            )),
                        Expanded(
                            child: ListView(
                          padding: const EdgeInsets.all(10),
                          shrinkWrap: true,
                          children: [
                            const SizedBox(height: 20),
                            DropdownButtonFormField<int>(
                                value: currentBankingId,
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF272626)),
                                validator: (val) =>
                                    val == null ? 'CAMPO REQUERIDO' : null,
                                onChanged: (c) {
                                  currentBankingId = c;
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  labelText: 'BANCO',
                                  enabledBorder: const OutlineInputBorder(
                                    //<-- SEE HERE
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    //<-- SEE HERE
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                                ),
                                hint: const Text('BANCO'),
                                enableFeedback: false,
                                isExpanded: true,
                                items: bankings
                                    .map((e) => DropdownMenuItem(
                                        value: e.id,
                                        child: Text(e.name.toString())))
                                    .toList()),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<int>(
                                value: currentBankingEntityId,
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF272626)),
                                validator: (val) =>
                                    val == null ? 'CAMPO REQUERIDO' : null,
                                onChanged: (c) {
                                  currentBankingEntityId = c;
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  labelText: 'ENTIDAD BANCARIA',
                                  enabledBorder: const OutlineInputBorder(
                                    //<-- SEE HERE
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    //<-- SEE HERE
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                                ),
                                hint: const Text('ENTIDAD BANCARIA'),
                                enableFeedback: false,
                                isExpanded: true,
                                items: bankingEntities
                                    .map((e) => DropdownMenuItem(
                                        value: e.id,
                                        child: Text(e.name.toString())))
                                    .toList()),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: checkNumber,
                              validator: (val) =>
                                  val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'NUMERO DE REFERENCIA',
                                  hintText: 'NUMERO DE REFERENCIA'),
                            ),
                            const SizedBox(height: 20),
                            BeneficiarySelectorWidget(
                              currentBeneficiary: currentBeneficiary,
                              companyDetailsPage: widget.companyDetailsPage,
                              onSelected: (b) {
                                currentBeneficiaryId = b?.id;
                                currentBeneficiary = b;
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: total,
                              validator: (val) =>
                                  val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                              inputFormatters: [myformatter],
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'MONTO DE CHEQUE',
                                  hintText: 'MONTO DE CHEQUE'),
                            ),
                            const SizedBox(height: 20),
                            DateSelectorWidget(
                                onSelected: (date) {
                                  checkDate = date;
                                },
                                hintText: 'FECHA DE PAGO',
                                labelText: 'FECHA DE PAGO',
                                stream: streamController,
                                startDate: startDate!,
                                date: checkDate),
                          ],
                        )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: SizedBox(
                            width: double.maxFinite,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: onSubmit, child: Text(btnTitle)),
                          ),
                        )
                      ],
                    )),
          )))
        ],
      ),
    );
  }
}
