// overlay_widget.dart
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  String messageBody = '📭 메시지 없음';
  ReceivePort? _receivePort;

  @override
  void initState() {
    super.initState();
    _initReceiver();
  }

  void _initReceiver() {
    _receivePort = ReceivePort();
    // 이름을 등록 (나중에 이 이름으로 SendPort를 찾을 수 있음)
    IsolateNameServer.registerPortWithName(
      _receivePort!.sendPort,
      'overlay_message_port',
    );

    _receivePort!.listen((data) {
      print('📨 오버레이 메시지 수신: $data');
      setState(() {
        messageBody = data.toString(); // 화면에 표시
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
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Center(
        child: Text(
          messageBody,
          style: const TextStyle(fontSize: 24, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
