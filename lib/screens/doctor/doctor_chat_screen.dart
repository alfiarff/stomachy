import 'package:flutter/material.dart';

import 'doctorr_home_screen.dart';
import 'doctor_patient_chat_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({super.key});

  // ===============================================================
  // DATA CHAT
  // ===============================================================

  static final List<Map<String, dynamic>> chatItems = [
    {
      'name': 'Jerome Polin',
      'message':
          'Pagi dok, saya sering merasa panas di dada dan asam naik ...',
      'time': '10:13',
      'unread': 2,
      'age': 21,
      'gender': 'Laki-laki',
      'genderIcon': Icons.male_rounded,
      'genderColor': Color(0xFF2385C7),
      'avatarColor': Color(0xFFE8E8E8),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF343434),
    },
    {
      'name': 'Nadia Putri',
      'message': 'Baik dok, terima kasih informasinya.',
      'time': '09:27',
      'unread': 1,
      'age': 20,
      'gender': 'Perempuan',
      'genderIcon': Icons.female_rounded,
      'genderColor': Color(0xFFE85C91),
      'avatarColor': Color(0xFFFFE4E1),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
    {
      'name': 'Raka Wijaya',
      'message': 'Apakah saya boleh mengkonsumsi kopi dok?',
      'time': 'Kemarin',
      'unread': 0,
      'age': 22,
      'gender': 'Laki-laki',
      'genderIcon': Icons.male_rounded,
      'genderColor': Color(0xFF2385C7),
      'avatarColor': Color(0xFFE6E1FF),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
    {
      'name': 'Sinta Maharani',
      'message':
          'Baik dok, saya akan coba menghindari makanan pedas.',
      'time': 'Kemarin',
      'unread': 0,
      'age': 23,
      'gender': 'Perempuan',
      'genderIcon': Icons.female_rounded,
      'genderColor': Color(0xFFE85C91),
      'avatarColor': Color(0xFFFFEBD9),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
    {
      'name': 'Dimas Arya',
      'message': 'Terima kasih dok atas sarannya.',
      'time': '2 hari lalu',
      'unread': 0,
      'age': 20,
      'gender': 'Laki-laki',
      'genderIcon': Icons.male_rounded,
      'genderColor': Color(0xFF2385C7),
      'avatarColor': Color(0xFFFFE8E0),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
    {
      'name': 'Aurel Safitri',
      'message':
          'Dok, apakah boleh makan malam setelah jam 8?',
      'time': '3 hari lalu',
      'unread': 0,
      'age': 21,
      'gender': 'Perempuan',
      'genderIcon': Icons.female_rounded,
      'genderColor': Color(0xFFE85C91),
      'avatarColor': Color(0xFFE9E2FF),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
    {
      'name': 'Fahri Maulana',
      'message':
          'Baik dok, saya mengerti. Terima kasih banyak.',
      'time': '5 hari lalu',
      'unread': 0,
      'age': 22,
      'gender': 'Laki-laki',
      'genderIcon': Icons.male_rounded,
      'genderColor': Color(0xFF2385C7),
      'avatarColor': Color(0xFFDDF4E9),
      'avatarIcon': Icons.person_rounded,
      'avatarIconColor': Color(0xFF5B4038),
    },
  ];

  @override
  State<DoctorChatScreen> createState() =>
      _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor = const Color(0xFFFFF5EF);

  final Color primaryBrown = const Color(0xFFB65339);

  // ===============================================================
  // SEARCH
  // ===============================================================

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  // ===============================================================
  // FILTER
  // ===============================================================

  bool _showUnreadOnly = false;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===============================================================
  // FILTER CHAT
  // ===============================================================

  List<Map<String, dynamic>> get _filteredChats {
    return DoctorChatScreen.chatItems.where((chat) {
      final String name =
          chat['name'].toString().toLowerCase();

      final bool matchesSearch =
          name.contains(_searchQuery);

      final bool matchesUnread =
          !_showUnreadOnly ||
          (chat['unread'] as int) > 0;

      return matchesSearch && matchesUnread;
    }).toList();
  }

  // ===============================================================
  // BUKA CHAT
  // ===============================================================

  void _openChat(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorPatientChatScreen(
          patient: patient,
        ),
      ),
    );
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    // -------------------------------------------------------------
    // BERANDA
    // -------------------------------------------------------------

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorHomeScreen(),
        ),
      );

      return;
    }

    // -------------------------------------------------------------
    // PASIEN
    // -------------------------------------------------------------

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorPatientsScreen(),
        ),
      );

      return;
    }

    // -------------------------------------------------------------
    // CHAT
    // -------------------------------------------------------------

    if (index == 2) {
      return;
    }

    // -------------------------------------------------------------
    // PROFIL
    // -------------------------------------------------------------

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const DoctorProfileScreen(),
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
    final List<Map<String, dynamic>> chats =
        _filteredChats;

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            const SizedBox(height: 8),

            // -----------------------------------------------------
            // SEARCH
            // -----------------------------------------------------

            Padding(
              padding: const EdgeInsets.fromLTRB(
                35,
                0,
                35,
                14,
              ),
              child: _buildSearchBar(),
            ),

            // -----------------------------------------------------
            // TAB
            // -----------------------------------------------------

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 33,
              ),
              child: _buildFilterTabs(),
            ),

            const SizedBox(height: 15),

            // -----------------------------------------------------
            // CHAT LIST
            // -----------------------------------------------------

            Expanded(
              child: chats.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics:
                          const BouncingScrollPhysics(),

                      padding:
                          const EdgeInsets.fromLTRB(
                        33,
                        0,
                        33,
                        15,
                      ),

                      itemCount: chats.length,

                      itemBuilder:
                          (context, index) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: _buildChatCard(
                            chats[index],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        28,
        10,
        28,
        0,
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 25,
                    color: Color(0xFFB65339),
                  ),
                ),
              ),
            ),

            const Expanded(
              child: Center(
                child: Text(
                  'Daftar Chat',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 40,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // SEARCH BAR
  // ===============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 48,

      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFA),

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: const Color(0xFFE76F51),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: TextField(
        controller: _searchController,

        textAlignVertical:
            TextAlignVertical.center,

        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          color: Colors.black,
        ),

        decoration: const InputDecoration(
          border: InputBorder.none,

          prefixIcon: Icon(
            Icons.search_rounded,
            size: 24,
            color: Colors.black,
          ),

          hintText: 'Cari nama pasien...',

          hintStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            color: Color(0xFF8C8582),
          ),

          contentPadding:
              EdgeInsets.symmetric(
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // FILTER TABS
  // ===============================================================

  Widget _buildFilterTabs() {
    return Row(
      children: [
        // ---------------------------------------------------------
        // SEMUA
        // ---------------------------------------------------------

        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showUnreadOnly = false;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),

              height: 42,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: !_showUnreadOnly
                    ? primaryBrown
                    : Colors.transparent,

                borderRadius:
                    BorderRadius.circular(22),

                border: Border.all(
                  color: primaryBrown,
                  width: 1,
                ),
              ),

              child: Text(
                'Semua',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: !_showUnreadOnly
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ---------------------------------------------------------
        // BELUM DIBACA
        // ---------------------------------------------------------

        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showUnreadOnly = true;
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),

              height: 42,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: _showUnreadOnly
                    ? primaryBrown
                    : Colors.transparent,

                borderRadius:
                    BorderRadius.circular(22),

                border: Border.all(
                  color: primaryBrown,
                  width: 1,
                ),
              ),

              child: Text(
                'Belum Dibaca',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _showUnreadOnly
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // CHAT CARD
  // ===============================================================

  Widget _buildChatCard(
    Map<String, dynamic> chat,
  ) {
    final int unread =
        chat['unread'] as int;

    return GestureDetector(
      onTap: () {
        _openChat(chat);
      },

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.fromLTRB(
          14,
          12,
          10,
          12,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.035),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            // -----------------------------------------------------
            // AVATAR
            // -----------------------------------------------------

            Container(
              width: 62,
              height: 62,

              decoration: BoxDecoration(
                color: chat['avatarColor'],
                shape: BoxShape.circle,
              ),

              child: Icon(
                chat['avatarIcon'],
                size: 39,
                color: chat['avatarIconColor'],
              ),
            ),

            const SizedBox(width: 13),

            // -----------------------------------------------------
            // NAMA + PESAN
            // -----------------------------------------------------

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    chat['name'].toString(),

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    chat['message'].toString(),

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      height: 1.3,
                      color: Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // -----------------------------------------------------
            // WAKTU + UNREAD + ARROW
            // -----------------------------------------------------

            // DIBUAT 64 AGAR TIDAK OVERFLOW
            SizedBox(
              width: 64,

              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment:
                    CrossAxisAlignment.end,

                children: [
                  Text(
                    chat['time'].toString(),

                    maxLines: 1,

                    overflow:
                        TextOverflow.clip,

                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      color: Color(0xFF777777),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      // -------------------------------------------------
                      // UNREAD
                      // -------------------------------------------------

                      if (unread > 0)
                        Container(
                          width:
                              unread > 1 ? 25 : 10,

                          height:
                              unread > 1 ? 25 : 10,

                          alignment:
                              Alignment.center,

                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xFFB65339),
                            shape:
                                BoxShape.circle,
                          ),

                          child: unread > 1
                              ? Text(
                                  unread.toString(),
                                  style:
                                      const TextStyle(
                                    fontFamily:
                                        'Nunito',
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w800,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : null,
                        ),

                      // Spacer hanya kalau unread ada
                      if (unread > 0)
                        const SizedBox(width: 5),

                      // -------------------------------------------------
                      // CHEVRON
                      // -------------------------------------------------

                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 27,
                        color: Color(0xFFB65339),
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
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Container(
            width: 75,
            height: 75,

            decoration:
                const BoxDecoration(
              color: Color(0xFFFFE8DD),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 38,
              color: Color(0xFFB65339),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Chat tidak ditemukan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Coba cari nama pasien yang lain.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 94,

      decoration:
          const BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.only(
          topLeft:
              Radius.circular(30),
          topRight:
              Radius.circular(30),
        ),
      ),

      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 7,
        ),

        child: Row(
          children: [
            _buildNavigationItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Beranda',
            ),

            _buildNavigationItem(
              index: 1,
              icon: Icons.groups_rounded,
              label: 'Pasien',
            ),

            _buildNavigationItem(
              index: 2,
              icon:
                  Icons.chat_bubble_rounded,
              label: 'Chat',
            ),

            _buildNavigationItem(
              index: 3,
              icon:
                  Icons.person_outline_rounded,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // NAVIGATION ITEM
  // ===============================================================

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected =
        index == 2;

    return Expanded(
      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,

        onTap: () {
          _onNavigationTap(index);
        },

        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),

          margin:
              const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),

          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFE5D5)
                : Colors.transparent,

            borderRadius:
                BorderRadius.circular(27),
          ),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                size: 30,
                color:
                    const Color(0xFF93432F),
              ),

              const SizedBox(height: 3),

              Text(
                label,

                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,

                  fontWeight: isSelected
                      ? FontWeight.w800
                      : FontWeight.w500,

                  color:
                      const Color(0xFF784033),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}