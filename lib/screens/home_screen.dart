import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_content_service.dart';
import 'admin/admin_article_detail_screen.dart';
import 'dart:convert';

import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'screening_history_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'artikel_tidur_screen.dart';
import 'notification_screen.dart';

import '../widgets/bottom_navigation.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ===============================================================
  // WARNA STOMACHY
  // ===============================================================

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);
  final Color accentBrown = const Color(0xFFB9543A);
  final Color purple = const Color(0xFFB5A4E8);
  final Color brown = const Color(0xFFB05039);

  // ===============================================================
  // WARNA TEKS
  // ===============================================================

  static const Color headingDark = Color(0xFF251814);
  static const Color greetingDark = Color(0xFF4A2119);
  static const Color greetingBody = Color(0xFF764C43);
  static const Color bodyText = Color(0xFF6B5147);

  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // ===============================================================
  // LOAD NAMA PENGGUNA
  // ===============================================================

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      String name = user.displayName ?? '';

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          final firestoreName = data['name'];

          if (firestoreName is String && firestoreName.trim().isNotEmpty) {
            name = firestoreName.trim();
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _userName = name.isNotEmpty ? name : 'Pengguna';
      });
    } catch (e) {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      setState(() {
        _userName = user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : 'Pengguna';
      });
    }
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScreeningScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DoctorScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EdukasiScreen()),
      );
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 95),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),

              _buildHeader(),

              const SizedBox(height: 14),

              _buildGreeting(),

              const SizedBox(height: 16),

              _buildLatestScreeningCard(),

              const SizedBox(height: 22),

              // =====================================================
              // JUDUL SECTION
              // =====================================================
              const Text(
                'Apa yang ingin kamu lakukan saat ini?',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              _buildQuickActions(),

              const SizedBox(height: 26),

              _buildArticleSection(),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 75,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logo_beranda_baru.png',
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const _NotificationBell(),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );

              if (mounted) {
                setState(() {});
              }
            },
            child: StreamBuilder(
              stream: FirebaseAuth.instance.currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
              builder: (context, snapshot) {
                final user = FirebaseAuth.instance.currentUser;
                final data = snapshot.data?.data();

                final photoBase64 = data?['photoBase64'];
                final photoURL = user?.photoURL;

                Widget avatar;

                if (photoBase64 is String && photoBase64.isNotEmpty) {
                  try {
                    avatar = Image.memory(
                      base64Decode(photoBase64),
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.account_circle_rounded,
                          size: 37,
                          color: Color(0xFFB9543A),
                        );
                      },
                    );
                  } catch (_) {
                    avatar = const Icon(
                      Icons.account_circle_rounded,
                      size: 37,
                      color: Color(0xFFB9543A),
                    );
                  }
                } else if (photoURL != null && photoURL.isNotEmpty) {
                  avatar = Image.network(
                    photoURL,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.account_circle_rounded,
                        size: 37,
                        color: Color(0xFFB9543A),
                      );
                    },
                  );
                } else {
                  avatar = const Icon(
                    Icons.account_circle_rounded,
                    size: 37,
                    color: Color(0xFFB9543A),
                  );
                }

                return Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF5EF),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(child: avatar),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // GREETING CARD
  // ===============================================================

  Widget _buildGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDE3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Halo,',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            '$_userName! 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Bagaimana kondisi lambungmu hari ini?',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // HASIL SKRINING TERAKHIR
  // ===============================================================

  Widget _buildLatestScreeningCard() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: user == null
          ? null
          : FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('screening_history')
                .orderBy('createdAt', descending: true)
                .limit(1)
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFB9543A),
                ),
              ),
            ),
          );
        }

        final documents = snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return _buildNoScreeningCard();
        }

        return _buildScreeningDataContent(documents.first.data());
      },
    );
  }

  // ===============================================================
  // KARTU BELUM ADA RIWAYAT SKRINING
  // ===============================================================

  Widget _buildNoScreeningCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScreeningScreen()),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hasil Skrining Terakhir',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Belum ada hasil skrining',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Lakukan skrining untuk melihat\nkondisi lambungmu di sini.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildBrownButton(
                    label: 'Mulai Skrining',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreeningScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Image.asset(
              'assets/images/mascot_happy.png',
              width: 92,
              height: 92,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 92,
                  child: Icon(
                    Icons.health_and_safety_rounded,
                    size: 50,
                    color: Color(0xFFB9543A),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // KARTU HASIL SKRINING TERBARU
  // ===============================================================

  Widget _buildScreeningDataContent(Map<String, dynamic> data) {
    final bool isRisk = data['isRisk'] == true;

    final String status = isRisk ? 'Berisiko GERD' : 'Tidak Berisiko GERD';

    final Color statusColor = isRisk
        ? const Color(0xFFE93636)
        : const Color(0xFF18865A);

    final String date = _formatHistoryDate(data['createdAt']);

    final String mascot = isRisk
        ? 'assets/images/stomachy_worried.png'
        : 'assets/images/mascot_happy.png';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScreeningHistoryScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hasil Skrining Terakhir',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      status,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8A7A72),
                    ),
                  ),
                ],
              ),
            ),

            Image.asset(
              mascot,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 100,
                  child: Icon(
                    Icons.personal_injury_rounded,
                    size: 55,
                    color: Color(0xFFB9543A),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // TOMBOL COKLAT
  // ===============================================================

  Widget _buildBrownButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBrown,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // FORMAT TANGGAL
  // ===============================================================

  String _formatHistoryDate(dynamic createdAt) {
    if (createdAt is Timestamp) {
      final date = createdAt.toDate();

      final day = date.day.toString();
      final month = _monthName(date.month);
      final year = date.year.toString();

      return '$day $month $year';
    }

    return '-';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return months[month];
  }

  // ===============================================================
  // QUICK ACTIONS
  // ===============================================================

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.search_rounded,
            iconColor: brown,
            title: 'Skrining',
            subtitle: 'Cek risiko GERD-mu',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreeningScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.medical_services_outlined,
            iconColor: brown,
            title: 'Konsultasi',
            subtitle: 'Chat dengan dokter',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoctorScreen()),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.menu_book_rounded,
            iconColor: brown,
            title: 'Edukasi',
            subtitle: 'Belajar tentang GERD',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EdukasiScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // QUICK ACTION CARD
  // ===============================================================

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                // Background icon dibuat peach supaya
                // icon brown tetap terlihat jelas.
                color: Color(0xFFFFE1C8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 27, color: iconColor),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 9.5,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ARTICLE SECTION
  // ===============================================================


Widget _buildArticleSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Artikel Minggu Ini',
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),

      const SizedBox(height: 12),

      StreamBuilder<List<AdminArticle>>(
        stream: AdminContentService.articlesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Color(0xFFB9543A),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Text(
              'Artikel gagal dimuat.',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
              ),
            );
          }

          // Hanya tampilkan artikel yang sudah diterbitkan admin.
          final articles = (snapshot.data ?? [])
              .where((article) => article.isPublished)
              .toList();

          if (articles.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Text(
                'Belum ada artikel yang diterbitkan.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            );
          }

          // Artikel paling baru ditampilkan lebih dahulu.
          articles.sort((a, b) => b.id.compareTo(a.id));

          final article = articles.first;

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AdminArticleDetailScreen(article: article),
                ),
              );
            },
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: double.infinity,
              height: 126,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 105,
                    height: 105,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        article.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFFFE7D8),
                            child: const Icon(
                              Icons.article_outlined,
                              size: 40,
                              color: Color(0xFFB9543A),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            height: 1.25,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Baca Selengkapnya',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: brown,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: brown,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}
}

// ===============================================================
// TOMBOL LONCENG NOTIFIKASI
//
// Angka badge dimuat ulang setiap:
// 1. Widget pertama kali tampil
// 2. Kembali dari halaman notifikasi
// 3. Ada sinyal notifikasi baru dari NotificationService
//    -> angka langsung update tanpa pindah halaman.
// ===============================================================

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount();

    NotificationService.badgeSignal.addListener(_onBadgeSignal);
  }

  void _onBadgeSignal() {
    _refreshCount();
  }

  @override
  void dispose() {
    NotificationService.badgeSignal.removeListener(_onBadgeSignal);
    super.dispose();
  }

  Future<void> _refreshCount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _unreadCount = 0;
        });
      }
      return;
    }

    final int count = await AppNotification.getRecentUnreadCount(user.uid);

    if (!mounted) return;

    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = _unreadCount > 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationScreen()),
        );

        _refreshCount();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              hasUnread
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              size: 27,
              color: const Color(0xFFB05039),
            ),
          ),

          if (hasUnread)
            Positioned(
              right: -3,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFAA4E39),
                  shape: _unreadCount > 9
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: _unreadCount > 9
                      ? BorderRadius.circular(10)
                      : null,
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
