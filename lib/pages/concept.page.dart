import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class ConceptPage extends StatefulWidget {
  List<Concept> concepts;

  ConceptPage({super.key, this.concepts = const []});

  @override
  State<ConceptPage> createState() => _ConceptPageState();
}

class _ConceptPageState extends State<ConceptPage> {
  TextEditingController concept = TextEditingController();

  search() async {
    try {
      widget.concepts =
          await Concept.getConcepts(searchMode: true, words: concept.text);
      setState(() {});
    } catch (_) {}
  }

  init() async {
    widget.concepts = [
      Concept(name: 'CONCEPTO'),
      ...(await Concept.getConcepts())
    ];
    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        color: kWindowBorderColor,
        width: 1,
        child: LayoutWithBar(
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('CATALOGO DE CONCEPTOS'),
                  automaticallyImplyLeading: false,
                  actions: [
                    Row(
                      children: [
                        ToolButton(
                            onTap: () => Get.back(),
                            toolTip: 'CERRAR SELECTOR DE CONCEPTOS',
                            icon: const Icon(Icons.close)),
                      ],
                    )
                  ],
                ),
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: TextFormField(
                        controller: concept,
                        autofocus: true,
                        onChanged: (_) => search(),
                        inputFormatters: [UpperCaseTextFormatter()],
                        style: TextStyle(fontSize: kxDefaultFontSize),
                        decoration: InputDecoration(
                            hintText: 'BUSCAR...',
                            labelText: 'BUSCAR CONCEPTOS...',
                            suffixIcon: Padding(
                                padding:
                                    EdgeInsets.only(right: kDefaultPadding),
                                child: const Icon(Icons.search)),
                            border: const OutlineInputBorder()),
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: widget.concepts.length,
                            itemBuilder: (ctx, index) {
                              var concept = widget.concepts[index];
                              return ListTile(
                                onTap: () {
                                  Get.back(result: {
                                    'current': concept,
                                    'index': index
                                  });
                                },
                                title: Text(concept.name!,
                                    style:
                                        TextStyle(fontSize: kDefaultPadding)),
                              );
                            }))
                  ],
                ))));
  }
}
