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
  NcfEditorWidget(
      {super.key,
      this.validator,
      this.hintText = 'NUMERO DE COMPROBANTE',
      this.isNcfModifed = false,
      required this.currentNcfTypeId,
      required this.controller,
      required this.ncfs,
      required this.onChanged});

  @override
  State<NcfEditorWidget> createState() => _NcfEditorWidgetState();
}

class _NcfEditorWidgetState extends State<NcfEditorWidget> {
  
  NcfType? currentNcfType;

  bool get isReady {
    return currentNcfType?.ncfTag != null;
  }

  bool get isElectronic {
    if (!isReady) return false;
    return currentNcfType!.prefixId == 2;
  }

  @override
  void initState() {
    if (!mounted) return;
    setState(() {
      currentNcfType = widget.ncfs
          .firstWhere((element) => element.id == widget.currentNcfTypeId);
      if (widget.controller.text.isNotEmpty) {
        widget.controller.value =
            TextEditingValue(text: widget.controller.value.text.substring(3));
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
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DropdownButtonFormField<int?>(
              value: currentNcfType?.id,
              validator:!widget.isNcfModifed? widget.validator : null,
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error))),
              hint: const Text('TIPO DE COMPROBANTE'),
              dropdownColor: Colors.white,
              enableFeedback: false,
              isExpanded: true,
              focusColor: Colors.white,
              onChanged: (id) {
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
              },
              items: widget.ncfs.map((ncf) {
                return DropdownMenuItem(
                  value: ncf.id,
                  child: Text(ncf.name),
                );
              }).toList(),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: widget.controller,
            validator: (val) => isReady ? val!.isEmpty
                    ? 'CAMPO REQUERIDO'
                    : !(val.length == 8 || val.length == 10)
                        ? 'EL NUMERO DE DIGITOS DEBE SER 8 O 10'
                        : null
              :null,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            style: const TextStyle(fontSize: 18),
            enabled: isReady,
            maxLength: !isElectronic?8:10,
            decoration: InputDecoration(
                isDense: true,
                prefixIcon: isReady
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(currentNcfType!.ncfTag!,
                            style: const TextStyle(fontSize: 18)))
                    : null,
                hintText: widget.hintText,
                border: const OutlineInputBorder()),
          ),
        ),
      ],
    );
  }
}
