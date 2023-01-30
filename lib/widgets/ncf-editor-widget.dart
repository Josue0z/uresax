import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uresaxapp/models/ncftype.dart';

class NcfEditorWidget extends StatefulWidget {
  Function(String) onChanged;
  String? val;
  String? ncfVal;
  String? hintText;
  String? Function(int?)? validator;
  NcfEditorWidget(
      {super.key,
      this.validator,
      this.hintText = 'NUMERO DE COMPROBANTE',
      required this.onChanged,
      required this.val,
      required this.ncfVal});

  @override
  State<NcfEditorWidget> createState() => _NcfEditorWidgetState();
}

class _NcfEditorWidgetState extends State<NcfEditorWidget> {
  TextEditingController controller = TextEditingController();
  List<NcfType> ncfs = [NcfType(name: 'TIPO DE COMPROBANTE')];
  TextEditingController ncf = TextEditingController();
  int? currentNcfType;
  String? currentNcfTag;
  String value = '';

  Future<void> _initElements() async {
    try {
      var types = await NcfType.getNcfs();
      controller.addListener(() {
        value = '$currentNcfTag${controller.text}';
        widget.onChanged(value);
      });

      ncfs.addAll(types);
      var item = ncfs.firstWhere((element) => element.name == widget.val);
      currentNcfType = item.id;
      currentNcfTag = item.ncfTag ?? '';
      controller.value = TextEditingValue(text: widget.ncfVal!.substring(3));
      value = '$currentNcfTag${controller.text}';
      widget.onChanged(value);
    } catch (e) {
    } finally {
      setState(() {});
    }
  }

  @override
  void initState() {
    _initElements();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool get _checkEnabled {
    if (currentNcfTag != null) {
      return !currentNcfTag!.startsWith('E');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DropdownButtonFormField<int?>(
              value: currentNcfType,
              validator: widget.validator,
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).errorColor))),
              hint: const Text('TIPO DE COMPROBANTE'),
              dropdownColor: Colors.white,
              enableFeedback: false,
              isExpanded: true,
              focusColor: Colors.white,
              onChanged: (val) {
                if (val == null) {
                  controller.value = const TextEditingValue(text: '');
                  value = '';
                  widget.onChanged(value);
                  return;
                }
                setState(() {
                  currentNcfType = val;
                });
              },
              items: ncfs.map((ncf) {
                return DropdownMenuItem(
                  value: ncf.id,
                  child: Text(ncf.name),
                  onTap: () => setState(() {
                    currentNcfTag = ncf.ncfTag ?? '';
                    widget.onChanged('$currentNcfTag${controller.text}');
                  }),
                );
              }).toList(),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: controller,
            validator: currentNcfTag != null
                ? (val) => val!.isEmpty
                    ? 'CAMPO REQUERIDO'
                    : !(val.length == 8 || val.length == 10)
                        ? 'EL NUMERO DE DIGITOS DEBE SER 8 O 10'
                        : null
                : null,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            style: const TextStyle(fontSize: 18),
            enabled: currentNcfTag != null,
            maxLength: _checkEnabled ? 8 : 10,
            decoration: InputDecoration(
                isDense: true,
                prefixIcon: currentNcfTag != null
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(currentNcfTag ?? '',
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
