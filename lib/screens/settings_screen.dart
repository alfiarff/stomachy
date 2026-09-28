import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ===============================================================
  // SELECTED BOTTOM NAVIGATION
  // ===============================================================

  int _selectedIndex = 4;

  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);
  final Color accentBrown = const Color(0xFFB9543A);

  // ===============================================================
  // STATUS TOGGLE
  //
  // notificationApp = master toggle.
  // Kalau master OFF, 4 sub-notifikasi di bawahnya
  // menjadi redup dan tidak bisa diubah.
  // ===============================================================

  bool notificationApp = true;
  bool notifArtikel = true;
  bool notifEdukasi = true;
  bool notifOlahraga = true;
  bool notifMakanan = true;

  bool notifBalasanDokter = false;
  bool notifPengingatSkrining = false;

  bool _isLoading = true;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ===============================================================
  // LOAD PENGATURAN DARI FIRESTORE
  // ===============================================================

  Future<void> _loadSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();

          if (data != null) {
            final settings = data['settings'];

            if (settings is Map) {
              setState(() {
                notificationApp =
                    settings['notificationApp'] as bool? ??
                        notificationApp;

                notifArtikel =
                    settings['notifArtikel'] as bool? ??
                        notifArtikel;

                notifEdukasi =
                    settings['notifEdukasi'] as bool? ??
                        notifEdukasi;

                notifOlahraga =
                    settings['notifOlahraga'] as bool? ??
                        notifOlahraga;

                notifMakanan =
                    settings['notifMakanan'] as bool? ??
                        notifMakanan;

                notifBalasanDokter =
                    settings['notifBalasanDokter'] as bool? ??
                        notifBalasanDokter;

                notifPengingatSkrining =
                    settings['notifPengingatSkrining'] as bool? ??
                        notifPengingatSkrining;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('SETTINGS LOAD ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===============================================================
  // SIMPAN PENGATURAN KE FIRESTORE
  // ===============================================================

  Future<void> _saveSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'settings': {
            'notificationApp': notificationApp,
            'notifArtikel': notifArtikel,
            'notifEdukasi': notifEdukasi,
            'notifOlahraga': notifOlahraga,
            'notifMakanan': notifMakanan,
            'notifBalasanDokter': notifBalasanDokter,
            'notifPengingatSkrining': notifPengingatSkrining,
          },
          'settingsUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('SETTINGS SAVE ERROR: $e');
    }
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    // BERANDA
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // SKRINING
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    // DOKTER
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // EDUKASI
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // PROFIL
    if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFB9543A),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  105,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =============================================
                    // HEADER
                    // =============================================

                    _buildHeader(),

                    const SizedBox(height: 27),

                    // =============================================
                    // BAGIAN AKUN
                    // =============================================

                    _buildSectionTitle('Akun'),

                    const SizedBox(height: 10),

                    _buildAccountCard(),

                    const SizedBox(height: 23),

                    // =============================================
                    // BAGIAN NOTIFIKASI
                    // =============================================

                    _buildSectionTitle('Notifikasi'),

                    const SizedBox(height: 10),

                    // NOTIFIKASI APLIKASI + SUB-ITEM
                    _buildNotificationAppCard(),

                    const SizedBox(height: 10),

                    // BALASAN DOKTER
                    _buildSimpleNotificationCard(
                      icon: BootstrapIcons.chat_dots,
                      title: 'Balasan Dokter',
                      description:
                          'Balasan chat konsultasi dari dokter',
                      value: notifBalasanDokter,
                      onChanged: (value) {
                        setState(() {
                          notifBalasanDokter = value;
                        });

                        _saveSettings();
                      },
                    ),

                    const SizedBox(height: 10),

                    // PENGINGAT SKRINING MINGGUAN
                    _buildSimpleNotificationCard(
                      icon: BootstrapIcons.alarm,
                      title: 'Pengingat Skrining Mingguan',
                      description:
                          'Setiap Senin - 09.00 (jadwal tetap)',
                      value: notifPengingatSkrining,
                      onChanged: (value) {
                        setState(() {
                          notifPengingatSkrining = value;
                        });

                        _saveSettings();
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),

      // ===========================================================
      // BOTTOM NAVIGATION
      // ===========================================================

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
      height: 42,
      child: Row(
        children: [
          // =======================================================
          // TOMBOL KEMBALI
          // =======================================================

          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 45,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          // =======================================================
          // JUDUL
          // =======================================================

          const Expanded(
            child: Center(
              child: Text(
                'Pengaturan',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // =======================================================
          // PENYEIMBANG
          // =======================================================

          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF30221E),
      ),
    );
  }

  // ===============================================================
  // ACCOUNT CARD
  // ===============================================================

  Widget _buildAccountCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChangePasswordScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 58,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // =====================================================
            // ICON
            // =====================================================

            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE8D8),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  BootstrapIcons.lock,
                  size: 19,
                  color: Color(0xFFB9543A),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // =====================================================
            // TEXT
            // =====================================================

            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF30221E),
                    ),
                  ),

                  SizedBox(height: 1),

                  Text(
                    'Ganti kata sandi akun anda',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF493C37),
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // CHEVRON
            // =====================================================

            const Icon(
              Icons.chevron_right_rounded,
              size: 25,
              color: Color(0xFFB9543A),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // KARTU NOTIFIKASI APLIKASI
  // ===============================================================

  Widget _buildNotificationAppCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // BARIS UTAMA : MASTER TOGGLE
          // ======================================================

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8D8),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    BootstrapIcons.bell,
                    size: 19,
                    color: Color(0xFFB9543A),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifikasi Aplikasi',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF30221E),
                      ),
                    ),

                    SizedBox(height: 1),

                    Text(
                      'Pemberitahuan konten baru dari STOMACHY',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF493C37),
                      ),
                    ),
                  ],
                ),
              ),

              _buildCustomSwitch(
                value: notificationApp,
                onChanged: (value) {
                  setState(() {
                    notificationApp = value;
                  });

                  _saveSettings();
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ======================================================
          // SUB-ITEM NOTIFIKASI
          // ======================================================

          Opacity(
            opacity: notificationApp ? 1.0 : 0.45,
            child: Column(
              children: [
                _buildSubNotificationItem(
                  icon: BootstrapIcons.newspaper,
                  title: 'Artikel Mingguan',
                  description:
                      'Saat ada artikel mingguan baru',
                  value: notifArtikel,
                  onChanged: (value) {
                    setState(() {
                      notifArtikel = value;
                    });

                    _saveSettings();
                  },
                ),

                const SizedBox(height: 12),

                _buildSubNotificationItem(
                  icon: BootstrapIcons.book,
                  title: 'Edukasi',
                  description: 'Saat ada edukasi baru',
                  value: notifEdukasi,
                  onChanged: (value) {
                    setState(() {
                      notifEdukasi = value;
                    });

                    _saveSettings();
                  },
                ),

                const SizedBox(height: 12),

                _buildSubNotificationItem(
                  icon: BootstrapIcons.bicycle,
                  title: 'Rekomendasi Olahraga',
                  description:
                      'Saat rekomendasi olahraga baru',
                  value: notifOlahraga,
                  onChanged: (value) {
                    setState(() {
                      notifOlahraga = value;
                    });

                    _saveSettings();
                  },
                ),

                const SizedBox(height: 12),

                _buildSubNotificationItem(
                  icon: BootstrapIcons.egg_fried,
                  title: 'Rekomendasi Makanan',
                  description:
                      'Saat rekomendasi makanan baru',
                  value: notifMakanan,
                  onChanged: (value) {
                    setState(() {
                      notifMakanan = value;
                    });

                    _saveSettings();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SUB-ITEM NOTIFIKASI
  // ===============================================================

  Widget _buildSubNotificationItem({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        // =====================================================
        // SPASI + GARIS PUTUS-PUTUS
        // =====================================================

        const SizedBox(width: 20),

        _buildDashSegment(),

        const SizedBox(width: 19),

        // =====================================================
        // ICON
        // =====================================================

        SizedBox(
          width: 22,
          child: Icon(
            icon,
            size: 17,
            color: accentBrown,
          ),
        ),

        const SizedBox(width: 9),

        // =====================================================
        // TEKS
        // =====================================================

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF30221E),
                ),
              ),

              const SizedBox(height: 1),

              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF776C67),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // =====================================================
        // SWITCH
        // =====================================================

        _buildCustomSwitch(
          value: value,
          onChanged: notificationApp ? onChanged : null,
        ),
      ],
    );
  }

  // ===============================================================
  // KARTU NOTIFIKASI SEDERHANA
  // ===============================================================

  Widget _buildSimpleNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // =======================================================
          // ICON
          // =======================================================

          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE8D8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 19,
                color: accentBrown,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // =======================================================
          // TEXT
          // =======================================================

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF30221E),
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF493C37),
                  ),
                ),
              ],
            ),
          ),

          // =======================================================
          // SWITCH
          // =======================================================

          _buildCustomSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CUSTOM SWITCH
  //
  // ON  -> track coklat, thumb putih
  // OFF -> track abu terang, thumb putih
  // ===============================================================

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final bool enabled = onChanged != null;

    return GestureDetector(
      onTap: enabled
          ? () {
              onChanged!(!value);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 44,
        height: 25,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? accentBrown
              : const Color(0xFFE5DDD8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 19,
            height: 19,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // SEGMENT GARIS PUTUS-PUTUS VERTIKAL
  // ===============================================================

  Widget _buildDashSegment() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++) ...[
          Container(
            width: 2,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFFD9A08F),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          if (i != 2)
            const SizedBox(height: 5),
        ],
      ],
    );
  }
}