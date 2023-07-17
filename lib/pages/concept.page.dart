import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/concept.dart';
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
    widget.concepts =
        await Concept.getConcepts(searchMode: true, words: concept.text);
    setState(() {});
  }

  init() async {
    widget.concepts =  [Concept(name: 'CONCEPTO'),...(await Concept.getConcepts())];
    setState(() {
      
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('CATALOGO DE CONCEPTOS'),
          automaticallyImplyLeading: false,
          actions: [
            ToolButton(
                onTap: () => Get.back(),
                toolTip: 'CERRAR SELECTOR DE CONCEPTOS',
                icon: const Icon(Icons.close)),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: TextFormField(
                controller: concept,
                onChanged: (_) => search(),
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                    hintText: 'BUSCAR...',
                    labelText: 'BUSCAR CONCEPTOS...',
                    suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 19),
                        child: Icon(Icons.search)),
                    border: OutlineInputBorder()),
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: widget.concepts.length,
                    itemBuilder: (ctx, index) {
                      var concept = widget.concepts[index];
                      return ListTile(
                        onTap: () {
                          Get.back(
                              result: {'current': concept, 'index': index});
                        },
                        title: Text(concept.name!,
                            style: const TextStyle(fontSize: 20)),
                      );
                    }))
          ],
        ));
  }
}
