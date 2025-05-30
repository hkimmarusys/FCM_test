import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as local_notif;
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as overlay;
import 'firebase_options.dart';
import 'overlay/overlay_widget.dart';
import 'screens/home_screen.dart';
import 'dart:isolate';

final local_notif.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
local_notif.FlutterLocalNotificationsPlugin();

const local_notif.AndroidNotificationChannel channel = local_notif.AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: local_notif.Importance.high,
);

Future<void> requestOverlayPermission() async {
  final granted = await overlay.FlutterOverlayWindow.isPermissionGranted();
  if (!granted) {
    await overlay.FlutterOverlayWindow.requestPermission();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("📨 [백그라운드] 메시지 수신: ${message.notification?.body}");

  final canDraw = await overlay.FlutterOverlayWindow.isPermissionGranted();
  if (!canDraw) {
    print("⚠️ 오버레이 권한 없음");
    return;
  }

  await overlay.FlutterOverlayWindow.showOverlay(
    height: overlay.WindowSize.matchParent,
    width: overlay.WindowSize.matchParent,
    alignment: overlay.OverlayAlignment.center,
    flag: overlay.OverlayFlag.defaultFlag,
    visibility: overlay.NotificationVisibility.visibilityPublic,
    enableDrag: true,
  );

  // 2. SendPort 가져와서 메시지 전달
  final sendPort = IsolateNameServer.lookupPortByName('overlay_message_port');
  if (sendPort != null) {
    sendPort.send(message.notification?.body ?? '메시지 없음');
  } else {
    print("SendPort를 찾을 수 없습니다.");
  }
}


@pragma('vm:entry-point')
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayWidget(),
  ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Overlay Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
