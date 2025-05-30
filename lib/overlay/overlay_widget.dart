import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayWidget extends StatefulWidget {
  final String? message; // nullable message

  const OverlayWidget({super.key, this.message});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      FlutterOverlayWindow.closeOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayMessage = widget.message ?? 'test';

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black54,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Text(displayMessage),
          ),
        ),
      ),
    );
  }
}
