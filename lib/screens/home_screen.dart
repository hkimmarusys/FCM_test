import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as overlay;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    requestOverlayPermission();
    _initFCM();
  }

  Future<void> requestOverlayPermission() async {
    final granted = await overlay.FlutterOverlayWindow.isPermissionGranted();
    if (!granted) {
      await overlay.FlutterOverlayWindow.requestPermission();
    }
  }

  Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();
    final token = await messaging.getToken();
    setState(() => _token = token);
    print("🔑 FCM Token: $token");

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? message.data['title'];
      final body = message.notification?.body ?? message.data['body'];

      Fluttertoast.showToast(
        msg: "${title ?? ''}\n${body ?? ''}".trim(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM 테스트')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _token != null ? '📡 FCM Token:\n$_token' : '토큰 가져오는 중...',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
