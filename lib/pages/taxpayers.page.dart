// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/taxpayer.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class TaxPayersPage extends StatefulWidget {
  const TaxPayersPage({super.key});

  @override
  State<TaxPayersPage> createState() => _TaxPayersPageState();
}

class _TaxPayersPageState extends State<TaxPayersPage> {
  List<TaxPayer> taxpayers = [];
  _onDelete(TaxPayer taxPayer) async {
    try {
      var isConfirm = await showConfirm(context,
          title: 'DESEAS ELIMINAR ESTE CONTRIBUYENTE?');
      if (isConfirm != null && isConfirm) {
        await taxPayer.delete();
        taxpayers.remove(taxPayer);
        setState(() {});
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  Widget get content {
    if (taxpayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.list_outlined,
                size: 150, color: Theme.of(context).primaryColor)
          ],
        ),
      );
    }
    return ListView.builder(
        itemCount: taxpayers.length,
        itemBuilder: (ctx, index) {
          var taxpayer = taxpayers[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              taxpayer.taxPayerCompanyName!,
              style: TextStyle(fontSize: kxDefaultFontSize),
            ),
            trailing: Wrap(
              children: [
                IconButton(
                    onPressed: () => _onDelete(taxpayers[index]),
                    icon: const Icon(Icons.delete)),
                IconButton(
                    onPressed: () {
                      Get.back(result: taxpayer);
                    },
                    icon: const Icon(Icons.arrow_right))
              ],
            ),
          );
        });
  }

  _onSearch(String words) async {
    try {
      if (words.isEmpty) {
        taxpayers = [];
        setState(() {});
        return;
      }
      taxpayers = await TaxPayer.get(words: words);

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      width: 1,
      color: kWindowBorderColor,
      child: Scaffold(
        body: Column(
          children: [
            const CustomFrameWidgetDesktop(),
            Expanded(
                child: Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      title: const Text('CONTRIBUYENTES'),
                      actions: [
                        ToolButton(
                            toolTip: 'CERRAR CONTRIBUYENTES',
                            icon: const Icon(Icons.close),
                            onTap: () => Get.back())
                      ],
                    ),
                    body: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: kDefaultPadding),
                        child: Column(
                          children: [
                            SizedBox(height: kDefaultPadding),
                            TextFormField(
                              autofocus: true,
                              onChanged: _onSearch,
                              style: TextStyle(fontSize: kxDefaultFontSize),
                              inputFormatters: [UpperCaseTextFormatter()],
                              decoration: InputDecoration(
                                  hintText: 'BUSCAR... (RNC, RAZON SOCIAL)',
                                  labelText: 'BUSCAR...',
                                  
                                  suffixIcon: Wrap(
                                    runAlignment: WrapAlignment.center,
                                    children: [
                                      const Icon(Icons.search),
                                      SizedBox(width: kDefaultPadding)
                                    ],
                                  ),
                                  border: const OutlineInputBorder()),
                            ),
                            SizedBox(height: kDefaultPadding),
                            Expanded(child: content)
                          ],
                        ))))
          ],
        ),
      ),
    );
  }
}
