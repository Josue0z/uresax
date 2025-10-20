import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/pages/concept.page.dart';
import 'package:uresaxapp/utils/consts.dart';

class SelectorConceptWidget extends StatefulWidget {
  Concept? value;

  Function(Concept?, int?) onSelected;

  SelectorConceptWidget({super.key, required this.onSelected, this.value});

  @override
  State<SelectorConceptWidget> createState() => _SelectorConceptWidgetState();
}

class _SelectorConceptWidgetState extends State<SelectorConceptWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.value?.id != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONCEPTO',
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).primaryColor)),
                  SizedBox(height: kDefaultPadding)
                ],
              )
            : SizedBox(),
        InkWell(
          onTap: () async {
            var map = await Get.to<Map?>(() => ConceptPage(concepts: []));
            if (map is Map) {
              var c = map['current'] as Concept?;
              widget.onSelected(map['current'], map['index']);
              widget.value = c;
              setState(() {});
            }
          },
          child: Container(
            height: 60,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black38),
                borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                    child: Text(widget.value?.name ?? 'CONCEPTO',
                        style: TextStyle(fontSize: kFontSize))),
                const Icon(Icons.arrow_drop_down)
              ],
            ),
          ),
        )
      ],
    );
  }
}
