import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/check.dart';
import 'package:uresaxapp/pages/checks_page.dart';
import 'package:uresaxapp/pages/company_details.dart';

class CheckSelectorWidget extends StatefulWidget {
  final StreamController<String?> controller;
  final CompanyDetailsPage companyDetailsPage;

  Function(Check?) onSelected;

  CheckSelectorWidget(
      {super.key,
      required this.controller,
      required this.companyDetailsPage,
      required this.onSelected});

  @override
  State<CheckSelectorWidget> createState() => _CheckSelectorWidgetState();
}

class _CheckSelectorWidgetState extends State<CheckSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.controller.stream,
        builder: (ctx, s) {
          return InkWell(
            onTap: () async {
              try {
                var data = await Get.to(
                    () => ChecksPage(
                        companyDetailsPage: widget.companyDetailsPage,
                        isEditionMode: false),
                    preventDuplicates: false);

                if (data != 'closed') {
                  var check = data as Check?;
                  widget.controller.sink.add(check?.fullName);
                  widget.onSelected(check);
                }
              } catch (_) {}
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  Expanded(
                      child: Text(s.data ?? 'BANCO/ENTIDAD/NUM - BENEFICIARIO',
                          overflow: TextOverflow.ellipsis)),
                  const Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
          );
        });
  }
}
