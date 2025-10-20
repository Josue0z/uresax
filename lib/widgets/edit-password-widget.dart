import 'package:flutter/material.dart';

class EditPasswordWidget extends StatefulWidget {
   Function(String)?  onFieldSubmitted;
  TextEditingController? controller;
  String hintText;
  bool showPassword;

  EditPasswordWidget(
      {super.key,
      this.controller,
      this.hintText = 'CONTRASEÑA',
      this.onFieldSubmitted,
      this.showPassword = false});

  @override
  State<EditPasswordWidget> createState() => _EditPasswordWidgetState();
}

class _EditPasswordWidgetState extends State<EditPasswordWidget> {
  FocusNode? _focusNode;

  @override
  initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: const TextStyle(fontSize: 18),
      obscureText: !widget.showPassword,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: (val) => val!.isEmpty
          ? 'CAMPO REQUERIDO'
          : val.length <= 3
              ? 'LA CONTRASEÑA DEBE CONTENER COMO MINIMO 4 CARACTERES'
              : null,
      focusNode: _focusNode,
      decoration: InputDecoration(
          suffixIcon: Wrap(
            children: [
              IconButton(
                onPressed: () {
                  _focusNode?.requestFocus();
                  setState(() {
                    widget.showPassword = !widget.showPassword;
                  });
                },
                icon: Icon(widget.showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
              ),
              const SizedBox(width: 10)
            ],
          ),
          border: const OutlineInputBorder(),
          hintText: widget.hintText),
    );
  }
}
