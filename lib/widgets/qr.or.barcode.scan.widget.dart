import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:uresaxapp/apis/keyboard.handler.dart';

class QrOrBarcodeScanWidget extends StatefulWidget {
  final Widget child;

  Function(String) onScanCompleted;

  bool enabled;

  QrOrBarcodeScanWidget(
      {super.key,
      required this.child,
      required this.onScanCompleted,
      required this.enabled});

  @override
  State<QrOrBarcodeScanWidget> createState() => _QrOrBarcodeScanWidgetState();
}

class _QrOrBarcodeScanWidgetState extends State<QrOrBarcodeScanWidget>
    with WidgetsBindingObserver {
  Timer? _timer;
  final FocusNode _focusKeyb = FocusNode();
  DateTime _lastKeyPress = DateTime.now();
  String _scannedData = '';
  final KeyboardLayoutChanger _keyboardLayoutChanger = KeyboardLayoutChanger();

  bool isRun = false;

  bool _handleKeyEvent(KeyEvent event) {
    try {
      if (event is KeyDownEvent) {
        DateTime now = DateTime.now();
        Duration difference = now.difference(_lastKeyPress);
        _lastKeyPress = now;

        if (_timer != null) {
          _timer!.cancel();
        }

        if (difference.inMilliseconds < 50) {
          _scannedData += event.character ?? '';

          _timer = Timer(Duration(milliseconds: 50), () {
            widget.onScanCompleted(_scannedData);
            _scannedData = '';
            isRun = false;
          });
        } else {
          _scannedData += event.character ?? '';
        }
      }
      return true;
    } catch (e) {
      print(e);
    }
    return true;
  }

  _setupEvents() {
    print('start window');
    if (widget.enabled) {
      _keyboardLayoutChanger.changeKeyboardLayout('en');
      _focusKeyb.requestFocus();
    }
  }

  @override
  initState() {
    _setupEvents();

    if (widget.enabled) {
      WidgetsBinding.instance.addObserver(this);
    }
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setupEvents();
    }
  }

  @override
  dispose() {
    if (widget.enabled) {
      WidgetsBinding.instance.removeObserver(this);
      _focusKeyb.dispose();
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _setupEvents,
      child: KeyboardListener(
          focusNode: _focusKeyb,
          onKeyEvent: widget.enabled ? _handleKeyEvent : null,
          child: widget.child),
    );
  }
}
