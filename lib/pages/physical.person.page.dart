import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/provider.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class PhysicalPersonPage extends StatefulWidget {
  final String id;

  const PhysicalPersonPage({super.key, required this.id});
  @override
  State<PhysicalPersonPage> createState() => _PhysicalPersonPageState();
}

class _PhysicalPersonPageState extends State<PhysicalPersonPage> {
  TextEditingController id = TextEditingController();

  TextEditingController name = TextEditingController();

  final formKey = GlobalKey<FormState>();

  List<PhysicalPerson> physicalPersons = [];

  init() async {
    id.value = TextEditingValue(text: widget.id);
    physicalPersons = await PhysicalPerson.get();
    setState(() {});
  }

  selected(PhysicalPerson physicalPerson) {
    Get.back(result: physicalPerson);
  }

  addPerson() async {
    if (formKey.currentState!.validate()) {
      try {
        var person = PhysicalPerson(id: id.text, name: name.text);
        person = await person.create();
        Get.back(result: person);
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  delete(PhysicalPerson physicalPerson) async {
    try {
      var confirm = await showConfirm(context,
          title: 'DESEAS ELIMINAR ESTA PERSONA FISICA?');

      if (confirm != null && confirm) {
        await physicalPerson.delete();
        physicalPersons = await PhysicalPerson.get();

        setState(() {});
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
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
          title: const Text('CATALOGO DE PERSONAS JURIDICAS'),
          automaticallyImplyLeading: false,
          actions: [
            ToolButton(
                onTap: () => Get.back(),
                toolTip: 'CERRAR CATALOGO DE PERSONAS FISICAS',
                icon: const Icon(Icons.close)),
          ],
        ),
        body: Form(
            autovalidateMode: AutovalidateMode.always,
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: id,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (val) => val!.isEmpty
                              ? 'CAMPO REQUERIDO'
                              : val.length < 11 || val.length > 11
                                  ? 'LA CANTIDAD DE CARACTERES DEBE SER DE 11'
                                  : null,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'RNC/CEDULA',
                              labelText: 'RNC/CEDULA'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: name,
                          inputFormatters: [UpperCaseTextFormatter()],
                          validator: (val) => val!.isEmpty
                              ? 'CAMPO REQUERIDO'
                              : val.length <= 5
                                  ? 'LA CANTIDAD DE CARACTERES DEBE SER MAYOR QUE 5'
                                  : null,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'NOMBRE',
                              labelText: 'NOMBRE'),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.maxFinite,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: addPerson,
                              child: const Text('AÑADIR PERSONA FISICA')),
                        )
                      ],
                    )),
                const SizedBox(height: 10),
                Expanded(
                    child: ListView.builder(
                        itemCount: physicalPersons.length,
                        itemBuilder: (ctx, i) {
                          var physicalPerson = physicalPersons[i];
                          return ListTile(
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                      onPressed: () => selected(physicalPerson),
                                      icon: const Icon(
                                        Icons.arrow_right_sharp,
                                      )),
                                  IconButton(
                                      onPressed: () => delete(physicalPerson),
                                      icon: const Icon(Icons.delete)),
                                ],
                              ),
                              title: Text(physicalPerson.name,
                                  style: const TextStyle(fontSize: 20)),
                              subtitle: Text(physicalPerson.id,
                                  style: const TextStyle(fontSize: 15)));
                        }))
              ],
            )));
  }
}
