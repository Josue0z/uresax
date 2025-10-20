import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uresaxapp/models/ncftype.dart';

class NcfEditorWidget extends StatefulWidget {
  List<NcfType> ncfs = [NcfType(name: 'TIPO DE COMPROBANTE')];
  TextEditingController controller;
  Function(NcfType?) onChanged;
  String? hintText;
  String? Function(int?)? validator;

  int? currentNcfTypeId;

  bool isNcfModifed;

  FocusNode? focusNode;

  bool isSelectorEnabled = true;

  NcfEditorWidget(
      {super.key,
      this.validator,
      this.hintText = 'NUMERO DE COMPROBANTE',
      this.isNcfModifed = false,
      this.focusNode,
      required this.currentNcfTypeId,
      required this.controller,
      required this.ncfs,
      required this.onChanged,
      this.isSelectorEnabled = true});

  @override
  State<NcfEditorWidget> createState() => _NcfEditorWidgetState();
}

class _NcfEditorWidgetState extends State<NcfEditorWidget> {
  NcfType? currentNcfType;

  bool get isReady {
    return currentNcfType != null;
  }

  bool get isElectronic {
    if (!isReady) return false;
    return currentNcfType!.prefixId == 2;
  }

  @override
  void initState() {
    if (!mounted) return;
    setState(() {
      if (widget.currentNcfTypeId != null) {
        currentNcfType = widget.ncfs
            .firstWhere((element) => element.id == widget.currentNcfTypeId);
      }
      if (widget.controller.text.isNotEmpty) {
        widget.controller.value =
            TextEditingValue(text: widget.controller.value.text);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    currentNcfType = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int?>(
          key: widget.key,
          value: currentNcfType?.id,
          decoration: InputDecoration(
              labelText: 'TIPO DE COMPROBANTE',
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error)),
              errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.error))),
          hint: const Text('TIPO DE COMPROBANTE'),
          dropdownColor: Colors.white,
          enableFeedback: false,
          isExpanded: true,
          focusColor: Colors.white,
          onChanged: widget.isSelectorEnabled ? (id) {
            if (id == null) {
              widget.controller.value = TextEditingValue.empty;
              currentNcfType = null;
            } else {
              currentNcfType =
                  widget.ncfs.firstWhere((element) => element.id == id);
            }
            widget.currentNcfTypeId = id;
            widget.onChanged(currentNcfType);
            setState(() {});
          } : null,
          items: widget.ncfs.map((ncf) {
            return DropdownMenuItem(
              value: ncf.id,
              child: Text(ncf.fullName),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        TextFormField(
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          controller: widget.controller,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          style: const TextStyle(fontSize: 18),
          enabled: isReady,
          maxLength: !isElectronic ? 8 : 10,
          validator: isReady
              ? (val) {
                  if (isElectronic) {
                    if (val!.length < 10) {
                      return 'LA SECUENCIA DEBE SER DE 10 DIGITOS';
                    }
                  } else {
                    if (val!.length < 8) {
                      return 'LA SECUENCIA DEBE SER DE 8 DIGITOS';
                    }
                  }

                  return null;
                }
              : (v) => null,
          decoration: InputDecoration(
              isDense: true,
              prefixIcon: isReady
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(currentNcfType!.ncfTag!,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor)))
                  : null,
              hintText: widget.hintText,
              border: const OutlineInputBorder()),
        ),
      ],
    );
  }
}
