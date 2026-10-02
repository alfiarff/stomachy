import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';
import '../../widgets/admin_bottom_navigation.dart';

import 'admin_home_screen.dart';
import 'admin_article_screen.dart';
import 'admin_profile_screen.dart';

// ===============================================================
// KELOLA KONTEN (ADMIN)
//
// Tab: Edukasi | Makanan | Olahraga
// Menampilkan daftar konten per kategori.
// ===============================================================

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() =>
      _AdminContentScreenState();
}

class _AdminContentScreenState
    extends State<AdminContentScreen>
    with SingleTickerProviderStateMixin {
  final Color backgroundColor = const Color(0xFFFFF5EF);

  static const Color headingDark = Color(0xFF251814);
  static const Color bodyText = Color(0xFF6B5147);

  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == 2) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminHomeScreen(),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminArticleScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminProfileScreen(),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                15,
                10,
                15,
                0,
              ),
              child: _buildHeader('Kelola Konten'),
            ),

            const SizedBox(height: 14),

            // ================================================
            // TAB BAR
            // ================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFA9583C),
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  indicatorSize:
                      TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      const Color(0xFF5A392F),
                  labelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Edukasi'),
                    Tab(text: 'Makanan'),
                    Tab(text: 'Olahraga'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================================================
            // ISI TAB
            // ================================================

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildItemList(
                    AdminContentService.edukasiItems,
                    emptyLabel: 'Belum ada materi edukasi.',
                  ),

                  _buildItemList(
                    AdminContentService.foodItems,
                    emptyLabel:
                        'Belum ada rekomendasi makanan.',
                  ),

                  _buildItemList(
                    AdminContentService.sportItems,
                    emptyLabel:
                        'Belum ada rekomendasi olahraga.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),

      bottomNavigationBar: AdminBottomNavigation(
        selectedIndex: 2,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader(String title) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 42,
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

          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),

          const SizedBox(width: 42),
        ],
      ),
    );
  }

  // ===============================================================
  // DAFTAR ITEM KONTEN
  // ===============================================================

  Widget _buildItemList(
    List<AdminContentItem> items, {
    required String emptyLabel,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            color: Color(0xFF777777),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        15,
        0,
        15,
        95,
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildContentRow(items[i]),

            if (i != items.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildContentRow(AdminContentItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: headingDark,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  item.category,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.5,
                    color: bodyText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ================================================
          // AKSI
          // ================================================

          _buildMiniAction(
            icon: Icons.edit_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Fitur edit konten sedang dalam pengembangan.',
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          _buildMiniAction(
            icon: Icons.delete_outline_rounded,
            onTap: () {
              setState(() {
                AdminContentService.edukasiItems
                    .remove(item);
                AdminContentService.foodItems
                    .remove(item);
                AdminContentService.sportItems
                    .remove(item);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Konten dihapus.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEE5),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          size: 17,
          color: const Color(0xFFB9543A),
        ),
      ),
    );
  }
}