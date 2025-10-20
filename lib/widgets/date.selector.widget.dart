import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';

class DateSelectorWidget extends StatefulWidget {
  StreamController<String?> stream;

  Function(DateTime?) onSelected;

  String hintText;

  String labelText;

  DateTime startDate;

  DateTime? date;

  bool isPayNcf;

  bool isImportMode;

  DateSelectorWidget(
      {super.key,
      this.isPayNcf = false,
      this.isImportMode = false,
      this.hintText = 'FECHA',
      this.labelText = 'FECHA',
      required this.onSelected,
      required this.stream,
      required this.startDate,
      this.date});

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _showDatePicker() async {
    var d = await showDatePicker(
        context: context,
        builder: (ctx,widget){
          return Column(
            children: [
              const CustomFrameWidgetDesktop(),
              Expanded(child: widget!)
            ],
          );
        },
        initialDate: widget.date ?? widget.startDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(3000));
    if (d != null) {
      widget.stream.add(d.format(payload: 'DD/MM/YYYY'));
      widget.date = d;
    } else if (d == null && widget.isPayNcf) {
      widget.stream.add(null);
      widget.date = null;
    } else if (widget.isImportMode) {
      widget.date = null;
    }
    widget.onSelected(widget.date);
  }

  Widget get content {
    return StreamBuilder(
        stream: widget.stream.stream,
        builder: (c, s) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              s.data != null
                  ? Column(
                      children: [
                        Text(widget.labelText,
                            style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context).primaryColor)),
                        const SizedBox(height: 10)
                      ],
                    )
                  : Container(),
              InkWell(
                onTap: _showDatePicker,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(s.data ?? widget.hintText,
                              style: TextStyle(
                                  fontSize: s.data != null ? 18 : 17,
                                  color: s.data != null
                                      ? Colors.black
                                      : Theme.of(context).primaryColor))),
                      Icon(Icons.calendar_month,
                          color: Theme.of(context).primaryColor)
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  @override
  void dispose() {
    widget.stream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return content;
  }
}
