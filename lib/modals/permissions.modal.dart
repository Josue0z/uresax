import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/permissionc.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class PermissionsModalWidget extends StatefulWidget {
  final User user;
  const PermissionsModalWidget({super.key, required this.user});

  @override
  State<PermissionsModalWidget> createState() => _PermissionsModalWidgetState();
}

class _PermissionsModalWidgetState extends State<PermissionsModalWidget> {
  List<PermissionC> permissions = [];
  bool loading = true;
  bool error = false;

  initAsync() async {
    try {
      permissions = await PermissionC.get();
      setState(() {
        loading = false;
        error = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  @override
  void initState() {
    initAsync();
    super.initState();
  }

  Widget get content {
    if (loading) {
      return contentLoading;
    }

    if (error) {
      return contentError;
    }

    return contentFilled;
  }

  Widget get contentLoading {
    return const SizedBox(
      height: 350,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget get contentError {
    return SizedBox(
      height: 350,
      child: Center(
        child: Icon(Icons.warning,
            color: Theme.of(context).colorScheme.error, size: 95),
      ),
    );
  }

  Widget get contentFilled {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'PERMISOS',
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 24),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () => Get.back(), icon: const Icon(Icons.close))
            ],
          ),
          SizedBox(
            height: kDefaultPadding,
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
            children: [
              ...permissions.map((e) {
                var val = widget.user.permissions?.contains(e.name);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                      value: val,
                      onChanged: (value) {
                        if (val == true) {
                          widget.user.permissions?.remove(e.name);
                        } else {
                          widget.user.permissions?.add(e.name);
                        }

                        val = widget.user.permissions?.contains(e.name);
                        print(widget.user.permissions);

                        setState(() {});
                      }),
                  title: Text(e.displayName),
                );
              })
            ],
          )))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Dialog(
          child: SizedBox(
            width: 500,
            height: 500,
            child: Padding(
                padding: EdgeInsets.all(kDefaultPadding / 2),
                child: Column(children: [content])),
          ),
        )));
  }
}
