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
  static const int _consultationReminderBaseId = 200000;
  static const int _doctorReplyBaseId = 300000;
  static const int _patientMessageBaseId = 400000;

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

  static Future<tz.TZDateTime> scheduleWeeklyScreening() async {
    await cancelWeeklyScreening();

    final tz.Location location = _resolveLocation();
    final tz.TZDateTime scheduled = _nextMondayAt9(location);

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
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint(
      'NOTIFIKASI: Pengingat skrining dijadwalkan pertama kali pada $scheduled',
    );

    return scheduled;
  }

  static Future<void> cancelWeeklyScreening() async {
    await _plugin.cancel(kWeeklyScreeningId);
  }

  static int _consultationId(String consultationId) {
    final int hash = consultationId.hashCode.abs();
    return _consultationReminderBaseId + (hash % 50000);
  }

  static int _doctorReplyId(String messageId) {
    final int hash = messageId.hashCode.abs();
    return _doctorReplyBaseId + (hash % 50000);
  }

  static int _patientMessageId(String messageId) {
    final int hash = messageId.hashCode.abs();
    return _patientMessageBaseId + (hash % 50000);
  }

  static Future<void> scheduleConsultationReminder({
    required String consultationId,
    required DateTime consultationTime,
    required String doctorName,
    required String patientName,
    required bool forDoctor,
  }) async {
    if (consultationId.isEmpty) return;

    final tz.Location location = _resolveLocation();
    final tz.TZDateTime scheduled =
        tz.TZDateTime.from(consultationTime, location);

    if (!scheduled.isAfter(tz.TZDateTime.now(location))) {
      return;
    }

    final String body = forDoctor
        ? 'Konsultasi dengan $patientName sudah dimulai.'
        : 'Konsultasi dengan $doctorName sudah dimulai. Kamu bisa mulai chat sekarang.';

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'consultation_reminder',
        'Pengingat Konsultasi',
        channelDescription:
            'Pengingat saat konsultasi dengan dokter dimulai',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      _consultationId(consultationId),
      'Waktunya Konsultasi!',
      body,
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelConsultationReminder(
    String consultationId,
  ) async {
    if (consultationId.isEmpty) return;
    await _plugin.cancel(_consultationId(consultationId));
  }

  static Future<void> showDoctorReply({
    required String messageId,
    required String doctorName,
    required String message,
  }) async {
    if (messageId.isEmpty || message.trim().isEmpty) return;

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'doctor_reply',
        'Balasan Dokter',
        channelDescription:
            'Notifikasi saat dokter membalas pesan konsultasi',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      _doctorReplyId(messageId),
      'Dokter Membalas Pesanmu',
      '$doctorName: ${message.trim()}',
      details,
    );
  }

  static Future<void> showPatientMessage({
    required String messageId,
    required String patientName,
    required String message,
  }) async {
    if (messageId.isEmpty || message.trim().isEmpty) return;

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'patient_message',
        'Pesan Baru dari Pasien',
        channelDescription:
            'Notifikasi saat pasien mengirim pesan konsultasi',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      _patientMessageId(messageId),
      'Pesan Baru dari Pasien',
      '$patientName: ${message.trim()}',
      details,
    );
  }

  static Future<void> showBookingSuccess({
    required String consultationId,
    required String doctorName,
    required String day,
    required String time,
  }) async {
    if (consultationId.isEmpty) return;

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'consultation_booking',
        'Booking Konsultasi',
        channelDescription:
            'Notifikasi saat booking konsultasi berhasil',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      _consultationId(consultationId) + 50000,
      'Booking Berhasil',
      'Konsultasi dengan $doctorName pada $day, $time WIB berhasil dibuat.',
      details,
    );
  }

  static Future<void> syncWeeklyScreeningFromSettings() async {
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

  static tz.TZDateTime _nextMondayAt9(
    tz.Location location,
  ) {
    final tz.TZDateTime now = tz.TZDateTime.now(location);

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
