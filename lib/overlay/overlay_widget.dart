// overlay_widget.dart
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  String messageBody = '메시지 없음';
  ReceivePort? _receivePort;

  @override
  void initState() {
    super.initState();
    _initReceiver();


  }

  void _initReceiver() {
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _receivePort!.sendPort,
      'overlay_message_port',
    );

    _receivePort!.listen((data) {
      print('오버레이 메시지 수신: $data');
      setState(() {
        messageBody = data.toString();
      });
    });
  }

  @override
  void dispose() {
    if (_receivePort != null) {
      IsolateNameServer.removePortNameMapping('overlay_message_port');
      _receivePort!.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                messageBody,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
