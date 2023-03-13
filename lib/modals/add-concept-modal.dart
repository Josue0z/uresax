import 'package:flutter/material.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class AddConceptModal extends StatefulWidget {
  List<Concept> concepts;

  Concept? currentConcept;
  bool isEditing = false;
  AddConceptModal({super.key, this.concepts = const []});

  @override
  State<AddConceptModal> createState() => _AddConceptModalState();
}

class _AddConceptModalState extends State<AddConceptModal> {
  TextEditingController concept = TextEditingController();

  int id = -1;

  String get _title {
    return widget.isEditing ? 'EDITANDO CONCEPTO...' : 'AÑADIENDO CONCEPTO...';
  }

  String get _btnTitle {
    return widget.isEditing ? 'EDITAR CONCEPTO' : 'AÑADIR CONCEPTO';
  }

  Future<void> _onSubmit() async {
    try {
      var myconcept = Concept(id: id, name: concept.text);

      if (concept.text.characters.length >= 3) {
        if (!widget.isEditing) {
          await myconcept.create();
        } else {
          await myconcept.update();
        }
      }

      widget.concepts = await Concept.getConcepts();
      _reset();
      return;
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  void _select(Concept c) {
    setState(() {
      id = c.id!;
      widget.currentConcept = c;
      widget.isEditing = true;
      concept.value = TextEditingValue(text: c.name!);
    });
  }

  Future<void> _delete() async {
    try {
      if (widget.currentConcept != null) {
        var isConfirm = await showConfirm(context, title: 'Eliminar Concepto?');
        if (isConfirm!) {
          await widget.currentConcept?.delete();
          widget.concepts = await Concept.getConcepts();
          _reset();
        }
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  void _reset() {
    setState(() {
      id = -1;
      widget.currentConcept = null;
      widget.isEditing = false;
      concept.value = TextEditingValue.empty;
    });
  }

  @override
  void dispose() {
    concept.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog(
          child: Form(
              child: SizedBox(
                  width: 500,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(_title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor)),
                              const Spacer(),
                              IconButton(
                                  onPressed: _reset,
                                  color: Theme.of(context).primaryColor,
                                  icon: const Icon(Icons.restore)),
                              IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: concept,
                            inputFormatters: [UpperCaseTextFormatter()],
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'CONCEPTO'),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                              child: ListView(
                            children: widget.concepts
                                .map((e) => ListTile(
                                      title: Text(e.name!),
                                      selected: widget.currentConcept != null
                                          ? e.name ==
                                              widget.currentConcept!.name!
                                          : false,
                                      onTap: () => _select(e),
                                      trailing: IconButton(
                                          onPressed: _delete,
                                          icon: const Icon(Icons.delete)),
                                    ))
                                .toList(),
                          )),
                          SizedBox(
                            width: double.maxFinite,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: _onSubmit, child: Text(_btnTitle)),
                          )
                        ],
                      ))))),
    );
  }
}
