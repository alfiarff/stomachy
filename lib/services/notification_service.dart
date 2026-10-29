import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../screens/notification_screen.dart';
import '../services/admin_content_service.dart';
import '../screens/user_content_detail_screen.dart';
import '../screens/admin/admin_article_detail_screen.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Map<String, dynamic>? _pendingContentPayload;
  static bool _contentNavigationReady = false;
  static bool _handlingContentTap = false;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (
        NotificationResponse response,
      ) {
        _handleNotificationTap(response.payload);
      },
    );

    // Tangani notifikasi yang membuka aplikasi dari kondisi tertutup.
    final launchDetails =
        await _plugin.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      _handleNotificationTap(
        launchDetails?.notificationResponse?.payload,
      );
    }

    await _setupFirebaseMessaging();
    await syncWeeklyScreeningFromSettings();

    debugPrint('NotificationService berhasil diinisialisasi.');
  }

  static void _handleNotificationTap(String? payload) {
    if (payload == null || payload.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(payload);

      if (decoded is! Map) {
        debugPrint('NOTIFIKASI: format payload tidak valid.');
        return;
      }

      final type = decoded['type']
          ?.toString()
          .trim()
          .toLowerCase();

      final contentId = decoded['contentId']?.toString().trim();

      const supportedTypes = <String>{
        'artikel',
        'edukasi',
        'makanan',
        'olahraga',
      };

      if (type == null ||
          contentId == null ||
          contentId.isEmpty ||
          !supportedTypes.contains(type)) {
        debugPrint('NOTIFIKASI: payload konten tidak valid.');
        return;
      }

      // Simpan payload jika Navigator belum siap atau sedang bernavigasi.
      _pendingContentPayload = <String, dynamic>{
        'type': type,
        'contentId': contentId,
      };

      _openPendingContentNotification();
    } catch (e) {
      debugPrint('NOTIFIKASI: payload gagal dibaca: $e');
    }
  }

  /// Panggil setelah aplikasi dan Navigator siap digunakan.
  static void markContentNavigationReady() {
    _contentNavigationReady = true;
    _openPendingContentNotification();
  }

  static Future<void> _openPendingContentNotification() async {
    if (!_contentNavigationReady ||
        _handlingContentTap ||
        _pendingContentPayload == null) {
      return;
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final payload = _pendingContentPayload!;
    _pendingContentPayload = null;
    _handlingContentTap = true;

    try {
      final type = payload['type'] as String;
      final contentId = payload['contentId'] as String;

      if (type == 'artikel') {
        final doc = await FirebaseFirestore.instance
            .collection('articles')
            .doc(contentId)
            .get();

        if (!doc.exists) {
          debugPrint('NOTIFIKASI: artikel tidak ditemukan: $contentId');
          return;
        }

        final article = AdminArticle.fromFirestore(doc);

        await navigator.push(
          MaterialPageRoute(
            builder: (_) =>
                AdminArticleDetailScreen(article: article),
          ),
        );

        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('contents')
          .doc(contentId)
          .get();

      if (!doc.exists) {
        debugPrint('NOTIFIKASI: konten tidak ditemukan: $contentId');
        return;
      }

      final content = AdminContentItem.fromFirestore(doc);

      await navigator.push(
        MaterialPageRoute(
          builder: (_) => UserContentDetailScreen(item: content),
        ),
      );
    } catch (e) {
      debugPrint(
        'NOTIFIKASI: gagal membuka detail dari popup: $e',
      );
    } finally {
      _handlingContentTap = false;

      // Proses ketukan berikutnya jika ada.
      if (_pendingContentPayload != null) {
        _openPendingContentNotification();
      }
    }
  }

  static const int kWeeklyScreeningId = 1001;
  static const int _consultationReminderBaseId = 200000;
  static const int _doctorReplyBaseId = 300000;
  static const int _patientMessageBaseId = 400000;

  // =============================================================
  // ID BASE UNTUK NOTIFIKASI KONTEN (BARU)
  // =============================================================
  static const int _contentNotifBaseId = 500000;
  static const int _articleNotifBaseId = 550000;

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
            contentId: doc.id,
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
            contentId: doc.id,
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
  // GLOBAL CONTENT WATCHER (BARU)
  // Memantau koleksi `contents` dan `articles` untuk dokumen baru.
  // =============================================================

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _contentWatcherSub;

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _articlesWatcherSub;

  // Flag baseline: snapshot pertama dianggap sebagai kondisi awal
  // sehingga tidak memicu notifikasi untuk konten yang sudah ada.
  static bool _contentBaselineEstablished = false;
  static bool _articlesBaselineEstablished = false;

  // Menyimpan ID konten/artikel yang sudah dikenal (baseline).
  static final Set<String> _knownContentIds = <String>{};
  static final Set<String> _knownArticleIds = <String>{};

  // Tipe konten yang akan memicu notifikasi (selain artikel).
  static const List<String> _watchedContentTypes = <String>[
    'edukasi',
    'makanan',
    'olahraga',
  ];

  /// Memulai watcher untuk konten (edukasi/makanan/olahraga) dan artikel.
  /// Panggil bersamaan dengan startChatWatcher() saat user login.
  static Future<void> startContentWatcher() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // Reset baseline setiap kali watcher dimulai.
    await stopContentWatcher();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    _contentWatcherSub = firestore
        .collection('contents')
        .snapshots()
        .listen(_handleContentSnapshot);

    _articlesWatcherSub = firestore
        .collection('articles')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .listen(_handleArticlesSnapshot);

    debugPrint('CONTENT WATCHER: aktif untuk user ${user.uid}');
  }

  static Future<void> stopContentWatcher() async {
    await _contentWatcherSub?.cancel();
    await _articlesWatcherSub?.cancel();

    _contentWatcherSub = null;
    _articlesWatcherSub = null;
    _contentBaselineEstablished = false;
    _articlesBaselineEstablished = false;
    _knownContentIds.clear();
    _knownArticleIds.clear();

    debugPrint('CONTENT WATCHER: dihentikan.');
  }

  /// Menangani snapshot koleksi `contents`.
  /// Snapshot pertama = baseline (tidak mengirim notifikasi).
  /// Snapshot berikutnya: dokumen baru = kirim notifikasi.
  static Future<void> _handleContentSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Snapshot pertama: tandai semua dokumen yang sudah ada sebagai baseline.
    if (!_contentBaselineEstablished) {
      for (final doc in snapshot.docs) {
        _knownContentIds.add(doc.id);
      }
      _contentBaselineEstablished = true;
      debugPrint(
        'CONTENT WATCHER: baseline ${snapshot.docs.length} contents',
      );
      return;
    }

    // Snapshot berikutnya: proses hanya dokumen yang benar-benar baru.
    for (final doc in snapshot.docs) {
      if (_knownContentIds.contains(doc.id)) continue;
      _knownContentIds.add(doc.id);

      await _processNewContent(doc, user.uid);
    }
  }

  /// Menangani snapshot koleksi `articles` (hanya yang isPublished = true).
  static Future<void> _handleArticlesSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!_articlesBaselineEstablished) {
      for (final doc in snapshot.docs) {
        _knownArticleIds.add(doc.id);
      }
      _articlesBaselineEstablished = true;
      debugPrint(
        'ARTICLES WATCHER: baseline ${snapshot.docs.length} articles',
      );
      return;
    }

    for (final doc in snapshot.docs) {
      if (_knownArticleIds.contains(doc.id)) continue;
      _knownArticleIds.add(doc.id);

      await _processNewArticle(doc, user.uid);
    }
  }

  /// Membuat notifikasi untuk dokumen `contents` baru.
  static Future<void> _processNewContent(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String uid,
  ) async {
    final data = doc.data();

    final String type =
        (data['type'] ?? '').toString().toLowerCase().trim();

    // Hanya tipe edukasi, makanan, olahraga yang diproses.
    if (!_watchedContentTypes.contains(type)) return;

    // Ambil judul konten — coba beberapa field yang umum dipakai.
    final String contentTitle = _pickTitle(data);
    if (contentTitle.isEmpty) return;

    // Tentukan metadata notifikasi berdasarkan tipe konten.
    final ({String notifType, String notifTitle}) meta =
        _contentMeta(type, contentTitle);

    final String notifId = 'content_${type}_${doc.id}';

    // Cek apakah notifikasi sudah pernah dibuat (anti-duplikat).
    final existingNotif = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .get();

    if (existingNotif.exists) {
      debugPrint('CONTENT WATCHER: notifikasi sudah ada untuk ${doc.id}');
      return;
    }

    try {
      // Notifikasi in-app selalu disimpan supaya muncul di halaman
      // notifikasi meskipun pengaturan kategori sedang OFF.
      await AppNotification.create(
        uid: uid,
        type: meta.notifType,
        title: meta.notifTitle,
        body: contentTitle,
        notificationId: notifId,
        respectSetting: false,
        contentId: doc.id,
      );

      // Notifikasi popup (HP) tetap mengikuti pengaturan kategori.
      await _showContentLocalNotification(
        notifType: meta.notifType,
        title: meta.notifTitle,
        body: contentTitle,
        contentId: doc.id,
      );

      _notifyBadgeChanged();

      debugPrint(
        'CONTENT WATCHER: notifikasi $type dibuat (${doc.id})',
      );
    } catch (e) {
      debugPrint('CONTENT WATCHER: gagal membuat notifikasi = $e');
    }
  }

  /// Membuat notifikasi untuk dokumen `articles` baru (isPublished = true).
  static Future<void> _processNewArticle(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String uid,
  ) async {
    final data = doc.data();

    // Pastikan artikel memang sudah dipublikasikan.
    if (data['isPublished'] != true) return;

    final String articleTitle = _pickTitle(data);
    if (articleTitle.isEmpty) return;

    final String notifId = 'article_${doc.id}';

    final existingNotif = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .get();

    if (existingNotif.exists) {
      debugPrint('ARTICLES WATCHER: notifikasi sudah ada untuk ${doc.id}');
      return;
    }

    try {
      await AppNotification.create(
        uid: uid,
        type: 'artikel',
        title: 'Artikel Baru Tersedia',
        body: articleTitle,
        notificationId: notifId,
        respectSetting: false,
        contentId: doc.id,
      );

      await _showContentLocalNotification(
        notifType: 'artikel',
        title: 'Artikel Baru Tersedia',
        body: articleTitle,
        contentId: doc.id,
      );

      _notifyBadgeChanged();

      debugPrint(
        'ARTICLES WATCHER: notifikasi artikel dibuat (${doc.id})',
      );
    } catch (e) {
      debugPrint('ARTICLES WATCHER: gagal membuat notifikasi = $e');
    }
  }

  /// Menampilkan notifikasi popup (HP) untuk konten/artikel baru.
  /// Mengikuti pengaturan kategori pengguna.
  static Future<void> _showContentLocalNotification({
    required String notifType,
    required String title,
    required String body,
    required String contentId,
  }) async {
    if (contentId.isEmpty || body.trim().isEmpty) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final bool enabled =
          await AppNotification.isCategoryEnabled(user.uid, notifType);

      // OFF hanya menghentikan popup HP, in-app notif tetap tersimpan.
      if (!enabled) {
        debugPrint(
          'NOTIFIKASI KONTEN $notifType DILEWATI: pengaturan OFF.',
        );
        return;
      }

      const NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          'content_updates',
          'Pembaruan Konten',
          channelDescription:
              'Notifikasi artikel, edukasi, makanan, dan olahraga baru',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      final int hash = contentId.hashCode.abs();
      final int baseId =
          notifType == 'artikel' ? _articleNotifBaseId : _contentNotifBaseId;
      final int localId = baseId + (hash % 50000);

      await _plugin.show(
        localId,
        title,
        body,
        details,
        payload: jsonEncode({
          'type': notifType,
          'contentId': contentId,
        }),
      );
    } catch (e) {
      debugPrint('NOTIFIKASI KONTEN LOCAL ERROR: $e');
    }
  }

  /// Mengambil judul dari data dokumen (mencoba beberapa field umum).
  /// Mengambil judul dari data dokumen (mencoba beberapa field umum).
  /// Mengambil judul dari data dokumen (mencoba beberapa field umum).
  static String _pickTitle(Map<String, dynamic> data) {
    // 1. Cek field top-level yang umum dipakai.
    final candidates = <String>[
      'title',
      'judul',
      'name',
      'nama',
    ];
    for (final key in candidates) {
      final value = data[key];
      if (value != null) {
        final str = value.toString().trim();
        if (str.isNotEmpty) return str;
      }
    }

    // 2. Cek nested di sections.title (untuk koleksi contents).
    final sections = data['sections'];
    if (sections is Map) {
      final sectionTitle = sections['title'];
      if (sectionTitle != null) {
        final str = sectionTitle.toString().trim();
        if (str.isNotEmpty) return str;
      }
    }

    // 3. Fallback ke summary kalau judul tetap kosong.
    final summary = data['summary'];
    if (summary != null) {
      final str = summary.toString().trim();
      if (str.isNotEmpty) return str;
    }

    return '';
  }

  /// Mengembalikan tipe notifikasi + judul header sesuai tipe konten.
static ({String notifType, String notifTitle}) _contentMeta(
  String type,
  String contentTitle,
) {
  switch (type) {
    case 'edukasi':
      return (
        notifType: 'edukasi',
        notifTitle: 'Edukasi Baru Tersedia',
      );
    case 'makanan':
      return (
        notifType: 'makanan',
        notifTitle: 'Rekomendasi Makanan Baru',
      );
    case 'olahraga':
      return (
        notifType: 'olahraga',
        notifTitle: 'Rekomendasi Olahraga Baru',
      );
    default:
      return (
        notifType: type,
        notifTitle: contentTitle,
      );
  }
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