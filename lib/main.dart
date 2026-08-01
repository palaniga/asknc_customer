import 'dart:async';
import 'dart:io';

import 'package:Asknc_user/my_app.dart';
import 'package:Asknc_user/services/cart.service.dart';
import 'package:Asknc_user/services/firebase.service.dart';
import 'package:Asknc_user/services/general_app.service.dart';
import 'package:Asknc_user/services/local_storage.service.dart';
import 'package:Asknc_user/services/notification.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'constants/app_languages.dart';

// ✅ SSL handshake override (only for Android/iOS)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// ✅ Background message handler must be top-level
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await GeneralAppService.onBackgroundMessageHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Apply HttpOverrides only on Android & iOS
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    HttpOverrides.global = MyHttpOverrides();
  }
  // ✅ Initialize Firebase
  await Firebase.initializeApp();
  // ✅ Initialize translator
  await translator.init(
    localeType: LocalizationDefaultType.asDefined,
    languagesList: AppLanguages.codes,
    assetsDirectory: 'assets/lang/',
  );
  // ✅ Load local storage and cart items
  await LocalStorageService.getPrefs();
  await CartServices.getCartItems();
  // ✅ Setup notifications (only for Android & iOS)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await NotificationService.clearIrrelevantNotificationChannels();
    await NotificationService.initializeAwesomeNotification();
    await NotificationService.listenToActions();
    await FirebaseService().setUpFirebaseMessaging();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  // ✅ Wrap in runZonedGuarded for global error catching
  runApp(
    LocalizedApp(
      child: MyApp(),
    ),
  );
}
