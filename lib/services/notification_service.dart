import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../screens/notification_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int kWeeklyScreeningId = 1001;
  static const int _consultationReminderBaseId = 200000;
  static const int _doctorReplyBaseId = 300000;
  static const int _patientMessageBaseId = 400000;

  // =============================================================
  // SINYAL PEMBARUAN BADGE LONCENG
  // =============================================================

  static final ValueNotifier<int> badgeSignal = ValueNotifier<int>(0);

  static void _notifyBadgeChanged() {
    badgeSignal.value = badgeSignal.value + 1;
  }

  // =============================================================
  // GLOBAL CHAT WATCHER
  // =============================================================

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _watcherSubAsPatient;

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _watcherSubAsDoctor;

  static String? _watcherUid;

  static final Set<String> _knownConsultationIds = <String>{};

  static final Set<String> _shownChatMessageIds = <String>{};

  static bool registerChatMessageIfNew(String messageId) {
    if (messageId.isEmpty) return false;

    if (_shownChatMessageIds.length > 2000) {
      _shownChatMessageIds.clear();
    }

    if (_shownChatMessageIds.contains(messageId)) return false;

    _shownChatMessageIds.add(messageId);
    return true;
  }

  static bool isChatMessageShown(String messageId) {
    return _shownChatMessageIds.contains(messageId);
  }

  static void markChatMessageShown(String messageId) {
    if (messageId.isEmpty) return;
    _shownChatMessageIds.add(messageId);
  }

  static Future<void> startChatWatcher() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final bool alreadyRunning =
        _watcherUid == user.uid &&
        (_watcherSubAsPatient != null ||
            _watcherSubAsDoctor != null);

    if (alreadyRunning) return;

    await stopChatWatcher();

    _watcherUid = user.uid;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    _watcherSubAsPatient = firestore
        .collection('consultations')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen(_handleConsultationSnapshot);

    _watcherSubAsDoctor = firestore
        .collection('consultations')
        .where('doctorId', isEqualTo: user.uid)
        .snapshots()
        .listen(_handleConsultationSnapshot);

    debugPrint('WATCHER: aktif untuk user ${user.uid}');
  }

  static Future<void> stopChatWatcher() async {
    await _watcherSubAsPatient?.cancel();
    await _watcherSubAsDoctor?.cancel();

    _watcherSubAsPatient = null;
    _watcherSubAsDoctor = null;
    _watcherUid = null;
    _knownConsultationIds.clear();

    debugPrint('WATCHER: dihentikan.');
  }

  static Future<void> _handleConsultationSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final String lastMessage =
          (data['lastMessage'] ?? '').toString().trim();

      final String lastSenderId =
          (data['lastSenderId'] ?? '').toString();

      final String lastMessageId =
          (data['lastMessageId'] ?? '').toString();

      // BASELINE PER KONSULTASI
      if (!_knownConsultationIds.contains(doc.id)) {
        _knownConsultationIds.add(doc.id);

        if (lastMessage.isEmpty || lastMessageId.isEmpty) {
          continue;
        }

        if (lastSenderId == user.uid) {
          _shownChatMessageIds.add(lastMessageId);
          continue;
        }
      }

      if (lastMessage.isEmpty) continue;
      if (lastMessageId.isEmpty) continue;

      if (lastSenderId == user.uid) {
        _shownChatMessageIds.add(lastMessageId);
        continue;
      }

      // Cegah notifikasi duplikat dari Firestore.
      final existingNotification = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc('chat_$lastMessageId')
          .get();

      if (existingNotification.exists) {
        _shownChatMessageIds.add(lastMessageId);
        continue;
      }

      // Cegah pemrosesan berulang dalam sesi aplikasi.
      if (_shownChatMessageIds.contains(lastMessageId)) continue;

      _shownChatMessageIds.add(lastMessageId);

      final String doctorId =
          (data['doctorId'] ?? '').toString();

      final bool iAmDoctor = doctorId == user.uid;

      String counterpartName = iAmDoctor
          ? (data['userName'] ?? data['name'] ?? '')
              .toString()
              .trim()
          : (data['doctorName'] ?? '').toString().trim();

      if (counterpartName.isEmpty) {
        counterpartName = iAmDoctor ? 'Pasien' : 'Dokter';
      }

      // Tampilkan gelar dr. pada nama dokter di notifikasi pasien.
      if (!iAmDoctor &&
          counterpartName.isNotEmpty &&
          !counterpartName.toLowerCase().startsWith('dr.')) {
        counterpartName = 'dr. $counterpartName';
      }

      try {
        if (iAmDoctor) {
          // Notifikasi untuk dokter saat pasien mengirim pesan.
          await showPatientMessage(
            messageId: lastMessageId,
            patientName: counterpartName,
            message: lastMessage,
          );

          await AppNotification.create(
            uid: user.uid,
            type: 'pesan_pasien',
            title: 'Pesan Baru dari $counterpartName',
            body: lastMessage,
            notificationId: 'chat_$lastMessageId',
            // BARU(ROUTE): simpan ID konsultasi agar kartu notif
            // bisa membuka ruang chat yang tepat saat dipencet.
            extraData: {'consultationId': doc.id},
          );
        } else {
          // Popup HP tetap mengikuti pengaturan Balasan Dokter.
          await showDoctorReply(
            messageId: lastMessageId,
            doctorName: counterpartName,
            message: lastMessage,
          );

          // Notifikasi in-app tetap disimpan meskipun pengaturan OFF.
          await AppNotification.create(
            uid: user.uid,
            type: 'chat',
            title: 'Pesan baru dari Dokter',
            body: '$counterpartName: "$lastMessage"',
            notificationId: 'chat_$lastMessageId',
            respectSetting: false,
            // BARU(ROUTE): simpan ID konsultasi agar kartu notif
            // bisa membuka ruang chat yang tepat saat dipencet.
            extraData: {'consultationId': doc.id},
          );
        }

        _notifyBadgeChanged();

        debugPrint(
          'WATCHER: notifikasi chat dibuat '
          '(messageId: $lastMessageId)',
        );
      } catch (e) {
        debugPrint('WATCHER: gagal membuat notifikasi chat = $e');
      }
    }
  }

  // =============================================================
  // INISIALISASI
  // =============================================================

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    await _setupFirebaseMessaging();

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

    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
  }

  static Future<void> _setupFirebaseMessaging() async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      final NotificationSettings settings =
          await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'FCM: authorizationStatus = ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus ==
          AuthorizationStatus.denied) {
        debugPrint('FCM: izin notifikasi ditolak.');
        return;
      }

      final String? token = await messaging.getToken();

      debugPrint('FCM TOKEN: $token');

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint(
          'FCM: token berhasil disimpan untuk user ${user.uid}',
        );
      }

      FirebaseMessaging.instance.onTokenRefresh.listen(
        (newToken) async {
          final currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser == null || newToken.isEmpty) {
            return;
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .set({
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          debugPrint('FCM: token diperbarui.');
        },
      );
    } catch (e) {
      debugPrint('FCM: gagal setup messaging: $e');
    }
  }

  // =============================================================
  // PENGINGAT SKRINING MINGGUAN
  // =============================================================

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
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint(
      'NOTIFIKASI: Pengingat skrining dijadwalkan pertama kali '
      'pada $scheduled',
    );

    return scheduled;
  }

  static Future<void> cancelWeeklyScreening() async {
    await _plugin.cancel(kWeeklyScreeningId);
  }

  // =============================================================
  // ID NOTIFIKASI
  // =============================================================

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

  // =============================================================
  // PENGINGAT JADWAL KONSULTASI
  // =============================================================

  static Future<void> scheduleConsultationReminder({
    required String consultationId,
    required DateTime consultationTime,
    required String doctorName,
    required String patientName,
    required bool forDoctor,
  }) async {
    if (consultationId.isEmpty) return;

    final tz.Location location = _resolveLocation();
    final tz.TZDateTime scheduled = tz.TZDateTime.from(
      consultationTime,
      location,
    );

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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelConsultationReminder(
    String consultationId,
  ) async {
    if (consultationId.isEmpty) return;
    await _plugin.cancel(_consultationId(consultationId));
  }

  // =============================================================
  // NOTIFIKASI CHAT LANGSUNG
  // =============================================================

  static Future<void> showDoctorReply({
    required String messageId,
    required String doctorName,
    required String message,
  }) async {
    if (messageId.isEmpty || message.trim().isEmpty) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final bool enabled =
          await AppNotification.isCategoryEnabled(user.uid, 'chat');

      // OFF hanya menghentikan popup HP, bukan penyimpanan in-app.
      if (!enabled) {
        debugPrint(
          'NOTIFIKASI BALASAN DOKTER DILEWATI: pengaturan OFF.',
        );
        return;
      }

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
        'Pesan baru dari Dokter',
        '$doctorName: ${message.trim()}',
        details,
      );
    } catch (e) {
      debugPrint('NOTIFIKASI BALASAN DOKTER ERROR: $e');
    }
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

  // =============================================================
  // SINKRONISASI PENGATURAN
  // =============================================================

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
      debugPrint('NOTIFIKASI: Gagal sinkronisasi pengaturan: $e');
    }
  }

  // =============================================================
  // HELPER TIMEZONE
  // =============================================================

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

  static tz.TZDateTime _nextMondayAt9(tz.Location location) {
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
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}