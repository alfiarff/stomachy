import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int kWeeklyScreeningId = 1001;

  // ===============================================================
  // INIT (dipanggil sekali di main.dart)
  // ===============================================================

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings =
        InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
  }

  // ===============================================================
  // JADWALKAN PENGINGAT SKRINING MINGGUAN
  // Setiap SENIN jam 09.00
  // ===============================================================

  static Future<tz.TZDateTime>
      scheduleWeeklyScreening() async {
    await cancelWeeklyScreening();

    final tz.Location location = _resolveLocation();

    final tz.TZDateTime scheduled =
        _nextMondayAt9(location);

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'weekly_screening',
        'Pengingat Skrining Mingguan',
        channelDescription:
            'Pengingat skrining GERD setiap Senin 09.00',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      kWeeklyScreeningId,
      'Saatnya Cek Lambungmu! 🌟',
      'Jangan lupa lakukan skrining mingguan GERD hari ini ya.',
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint(
      'NOTIFIKASI: Pengingat skrining dijadwalkan '
      'pertama kali pada $scheduled',
    );

    return scheduled;
  }

  // ===============================================================
  // BATALKAN PENGINGAT
  // ===============================================================

  static Future<void> cancelWeeklyScreening() async {
    await _plugin.cancel(kWeeklyScreeningId);
  }

  // ===============================================================
  // SINKRONISASI DENGAN PENGATURAN DI FIRESTORE
  // ===============================================================

  static Future<void>
      syncWeeklyScreeningFromSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        await cancelWeeklyScreening();
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      final settings = data?['settings'];

      final bool enabled = settings is Map
          ? settings['notifPengingatSkrining'] == true
          : false;

      if (enabled) {
        await scheduleWeeklyScreening();
      } else {
        await cancelWeeklyScreening();
      }
    } catch (e) {
      debugPrint(
        'NOTIFIKASI: Gagal sinkronisasi pengaturan: $e',
      );
    }
  }

  // ===============================================================
  // ZONA WAKTU PENGGUNA (WIB / WITA / WIT)
  // ===============================================================

  static tz.Location _resolveLocation() {
    final offset = DateTime.now().timeZoneOffset;

    if (offset.inHours == 8) {
      return tz.getLocation('Asia/Makassar');
    }

    if (offset.inHours == 9) {
      return tz.getLocation('Asia/Jayapura');
    }

    return tz.getLocation('Asia/Jakarta');
  }

  // ===============================================================
  // CARI SENIN BERIKUTNYA JAM 09.00
  // ===============================================================

  static tz.TZDateTime _nextMondayAt9(
    tz.Location location,
  ) {
    final tz.TZDateTime now =
        tz.TZDateTime.now(location);

    tz.TZDateTime scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      9,
      0,
    );

    while (scheduled.weekday != DateTime.monday ||
        !scheduled.isAfter(now)) {
      scheduled = scheduled.add(
        const Duration(days: 1),
      );
    }

    return scheduled;
  }
}