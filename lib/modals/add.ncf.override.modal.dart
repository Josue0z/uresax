// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/ncfs.override.controller.dart';
import 'package:uresaxapp/models/ncf.override.model.dart';
import 'package:uresaxapp/models/ncf.override.type.model.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/date.selector.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uresaxapp/widgets/ncf-editor-widget.dart';
import 'package:uuid/uuid.dart';

class NcfOverrideModal extends StatefulWidget {
  NcfOverrideModel? ncfOverrideModel;
  CompanyDetailsPage companyDetailsPage;
  bool isEditing = false;
  NcfOverrideModal(
      {super.key,
      required this.companyDetailsPage,
      this.ncfOverrideModel,
      this.isEditing = false});

  @override
  State<NcfOverrideModal> createState() => _NcfOverrideModalState();
}

class _NcfOverrideModalState extends State<NcfOverrideModal> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  NcfType? currentNcfType;
  int? currentNcfTypeId;

  List<NcfType> ncfs = [];

  List<NcfTypeOverride> ncfsTypesOverride = [];

  TextEditingController ncfValue = TextEditingController();

  DateTime ncfDate = DateTime.now();

  StreamController<String?> ncfStreamDate = StreamController();

  String? currentTypeOfOverride;

  bool loading = true;

  String get title {
    return widget.isEditing
        ? 'EDITANDO COMPROBANTE...'
        : 'AÑADIENDO COMPROBANTE...';
  }

  String get btnTitle {
    return widget.isEditing ? 'EDITAR COMPROBANTE' : 'AÑADIR COMPROBANTE';
  }

  onSubmit() async {
    if (formKey.currentState!.validate()) {
      showLoader(context);
      try {
        var ncfOverride = NcfOverrideModel(
            id: widget.ncfOverrideModel?.id ?? const Uuid().v4(),
            authorId: User.current!.id!,
            companyId: widget.companyDetailsPage.company.id!,
            ncf: '${currentNcfType?.ncfTag}${ncfValue.text}',
            ncfTypeId: currentNcfTypeId!,
            typeOfOverride: currentTypeOfOverride!,
            ncfDate: ncfDate);

        if (!widget.isEditing) {
          await ncfOverride.create();
        } else {
          await ncfOverride.update();
        }
        var start = ncfDate.startOfMonth();
        var end = ncfDate.endOfMonth();
        var c = Get.find<NcfsOverrideController>();
        c.ncfsOverrides.value = await NcfOverrideModel.get(
            companyId: widget.companyDetailsPage.company.id!,
            startDate: start,
            endDate: end);

        widget.companyDetailsPage.startDate = start;

        widget.companyDetailsPage.endDate = end;

        widget.companyDetailsPage.date.value = TextEditingValue(
            text:
                '${start.format(payload: 'DD/MM/YYYY')} - ${end.format(payload: 'DD/MM/YYYY')}');

        await storage.write(
            key: "STARTDATE_ANULADOS_${widget.companyDetailsPage.company.id}",
            value: start.format(payload: 'YYYY-MM-DD'));
        await storage.write(
            key: 'ENDDATE_ANULADOS_${widget.companyDetailsPage.company.id}',
            value: end.format(payload: 'YYYY-MM-DD'));

        Get.back();

        if (widget.isEditing) {
          Get.back(result: 'UPDATE');
        } else {
          Get.back(result: 'DELETE');
        }
      } catch (e) {
        Get.back();
        showAlert(context, message: e.toString());
      }
    }
  }

  initAsync() async {
    try {
      ncfs = [NcfType(name: 'TIPO DE COMPROBANTE'), ...await NcfType.getNcfs()];
      ncfsTypesOverride = [
        NcfTypeOverride(name: 'TIPO DE ANULACION'),
        ...await NcfTypeOverride.get()
      ];
      if (widget.isEditing && widget.ncfOverrideModel != null) {
        ncfValue.value = TextEditingValue(
            text: widget.ncfOverrideModel?.ncf.substring(3) ?? '');
        ncfDate = widget.ncfOverrideModel!.ncfDate;
        ncfStreamDate.add(ncfDate.format(payload: 'DD/MM/YYYY'));
        currentNcfTypeId = widget.ncfOverrideModel?.ncfTypeId;
        currentNcfType =
            ncfs.where((element) => element.id == currentNcfTypeId).first;
        currentTypeOfOverride = widget.ncfOverrideModel?.typeOfOverride;
        setState(() {});
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    initAsync();
    ncfDate = widget.companyDetailsPage.startDate;
    ncfStreamDate.add(ncfDate.format(payload: 'DD/MM/YYYY'));
    super.initState();
  }

  Widget get contentFilled {
    return Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(kDefaultPadding),
          children: [
            Row(
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: Theme.of(context).primaryColor)),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close))
              ],
            ),
            SizedBox(height: kDefaultPadding),
            NcfEditorWidget(
                currentNcfTypeId: currentNcfTypeId,
                controller: ncfValue,
                ncfs: ncfs,
                validator: (val) => val == null ? 'CAMPO REQUERIDO' : null,
                onChanged: (ncfType) {
                  setState(() {
                    currentNcfTypeId = ncfType?.id;
                    currentNcfType = ncfType;
                  });
                }),
            DateSelectorWidget(
                startDate: ncfDate,
                onSelected: (date) {
                  ncfDate = date!;
                  setState(() {});
                },
                stream: ncfStreamDate,
                labelText: "FECHA DE COMPROBANTE",
                hintText: "FECHA DE COMPROBANTE",
                date: ncfDate),
            SizedBox(height: kDefaultPadding),
            DropdownButtonFormField<String>(
              value: currentTypeOfOverride,
              validator: (val) => val == null ? 'CAMPO REQUERIDO' : null,
              onChanged: (c) {
                currentTypeOfOverride = c;
                print(c);
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'TIPO DE ANULACION',
                enabledBorder: const OutlineInputBorder(
                  //<-- SEE HERE
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  //<-- SEE HERE
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error)),
                errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.error)),
              ),
              hint: const Text('TIPO DE ANULACION'),
              dropdownColor: Colors.white,
              enableFeedback: false,
              isExpanded: true,
              focusColor: Colors.white,
              items: ncfsTypesOverride
                  .map((e) => DropdownMenuItem(
                      value: e.code, child: Text(e.name.toString())))
                  .toList(),
            ),
            SizedBox(height: kDefaultPadding),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: onSubmit, child: Text(btnTitle)),
            )
          ],
        ));
  }

  Widget get loadingView {
    return const SizedBox(
        height: 460, child: Center(child: CircularProgressIndicator()));
  }

  Widget get content {
    if (loading) {
      return loadingView;
    }
    return contentFilled;
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Dialog(
                insetPadding: EdgeInsets.all(kDefaultPadding / 2),
                child: SizedBox(width: 400, child: content))));
  }
}
