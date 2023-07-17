import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/pages/concept.page.dart';

class SelectorConceptWidget extends StatefulWidget {
  int? value;

  List<Concept> concepts;

  Function(Concept?, int?) onSelected;

  SelectorConceptWidget(
      {super.key,
      required this.onSelected,
      this.concepts = const [],
      this.value});

  @override
  State<SelectorConceptWidget> createState() => _SelectorConceptWidgetState();
}

class _SelectorConceptWidgetState extends State<SelectorConceptWidget> {
  Concept? get currentConcept {
    var c = widget.concepts.firstWhere((element) => element.id == widget.value);
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          var map =
              await Get.to<Map?>(() => ConceptPage(concepts: widget.concepts));
          if (map is Map) {
            var c = map['current'] as Concept?;
            widget.onSelected(map['current'], map['index']);
            widget.value = c?.id;
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
              Text(currentConcept?.name
               ?? 'CONCEPTO',
              style: const TextStyle(fontSize: 17)),
              const Spacer(),
              const Icon(Icons.arrow_drop_down)
            ],
          ),
        ));
  }
}
