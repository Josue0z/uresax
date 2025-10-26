// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/invoice.type.context.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class AddConceptModal extends StatefulWidget {
  List<Concept> concepts;
  List<InvoiceTypeContext> invoiceTypesContext;

  Concept? currentConcept;
  bool isEditing = false;
  AddConceptModal(
      {super.key,
      this.concepts = const [],
      this.invoiceTypesContext = const []});

  @override
  State<AddConceptModal> createState() => _AddConceptModalState();
}

class _AddConceptModalState extends State<AddConceptModal> {
  TextEditingController concept = TextEditingController();

  TextEditingController search = TextEditingController();

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

  _onSearch(words) async {
    try {
      widget.concepts =
          await Concept.getConcepts(words: words, searchMode: true);
      setState(() {});
    } catch (_) {}
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
        var isConfirm =
            await showConfirm(context, title: '¿Eliminar Concepto?');
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

  _reset() async {
    try {
      setState(() {
        id = -1;
        widget.currentConcept = null;
        widget.isEditing = false;
        search.clear();
        concept.clear();
      });
      widget.concepts = await Concept.getConcepts();
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _onSelectInvoiceTypeContext(int? value, Concept concept, int index) async {
    try {
      concept.typeContextId = value;

      widget.concepts[index].typeContextId = value;

      await concept.update();

      setState(() {});
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  @override
  void dispose() {
    concept.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Dialog(
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
                                                color: Theme.of(context)
                                                    .primaryColor)),
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
                                  controller: search,
                                  autofocus: true,
                                  onChanged: _onSearch,
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      suffixIcon: Wrap(
                                        alignment: WrapAlignment.center,
                                        runAlignment: WrapAlignment.center,
                                        children: [
                                          Icon(Icons.search),
                                          SizedBox(width: 10)
                                        ],
                                      ),
                                      labelText: 'BUSCAR...',
                                      hintText: 'BUSCAR...'),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: concept,
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'CONCEPTO',
                                      hintText: 'CONCEPTO'),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                    child: ListView(
                                  children: List.generate(
                                      widget.concepts.length, (index) {
                                    var e = widget.concepts[index];
                                    return ListTile(
                                        title: Text(e.name!),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                        selected: widget.currentConcept != null
                                            ? e.name ==
                                                widget.currentConcept?.name
                                            : false,
                                        onTap: () => _select(e),
                                        trailing: Wrap(
                                          runAlignment: WrapAlignment.end,
                                          children: [
                                           enabledConceptByTypeContext ?  SizedBox(
                                              width: 120,
                                              child: DropdownButtonFormField(
                                                  initialValue: widget.concepts[index].typeContextId,
                                                  isExpanded: true,
                                                  focusColor: Colors
                                                      .transparent,
                                                  items: widget
                                                      .invoiceTypesContext
                                                      .map((e) =>
                                                          DropdownMenuItem(
                                                              value: e.id,
                                                              child:
                                                                  Text(e.name)))
                                                      .toList(),
                                                  onChanged: (value) =>
                                                      _onSelectInvoiceTypeContext(
                                                          value, e, index)),
                                            ):SizedBox(),
                                            IconButton(
                                                onPressed: _delete,
                                                icon: const Icon(Icons.delete)),
                                          ],
                                        ));
                                  }),
                                )),
                                SizedBox(
                                  width: double.maxFinite,
                                  height: 50,
                                  child: ElevatedButton(
                                      onPressed: _onSubmit,
                                      child: Text(_btnTitle)),
                                )
                              ],
                            )))))));
  }
}
