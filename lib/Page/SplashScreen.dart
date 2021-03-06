import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'package:flutter_app_hyuabot_v2/Config/AdManager.dart';
import 'package:flutter_app_hyuabot_v2/Config/GlobalVars.dart';


void initApp() async {
  final String srcPath = path.join("assets/databases", "information.db");
  final String destPath = path.join((await getDatabasesPath())!, "information.db");
  final int srcSize = prefManager!.getInt("databaseSize") ?? 0;

  ByteData srcData = await rootBundle.load(srcPath);
  await Directory(path.dirname(destPath)).create(recursive: true);
  await deleteDatabase(destPath);
  List<int> bytes = srcData.buffer.asUint8List(srcData.offsetInBytes, srcData.lengthInBytes);
  await new File(destPath).writeAsBytes(bytes, flush: true);
  prefManager!.setInt("databaseSize", srcData.lengthInBytes);
  // Ad
  adController.setTestDeviceIds(["9EB3D1FB602993E0660E26FD66A53A25"]);
  adController.reloadAd(forceRefresh: true, numberAds: 3);
  adController.setAdUnitID(AdManager.bannerAdUnitId);

  // Alarm
  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  const AndroidInitializationSettings _initialSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings _settings = InitializationSettings(android: _initialSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(_settings, onSelectNotification: whenSelectNotification);
}

Future whenSelectNotification(String? payload) async{
  prefManager!.setBool(payload!, false);
  fcmManager!.unsubscribeFromTopic("$payload.ko_KR");
  fcmManager!.unsubscribeFromTopic("$payload.en_US");
  fcmManager!.unsubscribeFromTopic("$payload.zh");
  readingRoomController.fetchAlarm();
  selectNotificationSubject.addNotification(payload.tr());
}

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>{
  startTime() async {
    var _duration = new Duration(seconds: 1);
    initApp();
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void initState() {
    startTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Locale
    if (prefManager!.getString("localeCode") == null){
      final String defaultLocale = Platform.localeName;
      if(defaultLocale.startsWith("en")){
        prefManager!.setString("localeCode", "en_US");
        context.setLocale(Locale("en", "US"));
      } else if(defaultLocale.startsWith("zh")){
        prefManager!.setString("localeCode", "zh");
        context.setLocale(Locale("zh"));
      } else {
        prefManager!.setString("localeCode", "ko_KR");
        context.setLocale(Locale("ko", "KR"));
      }
    }
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("booting_app".tr(), textAlign: TextAlign.center,),
            SizedBox(height: 50,),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}


