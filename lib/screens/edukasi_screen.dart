import 'package:flutter/material.dart';

import '../services/admin_content_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/stomachy_cover_image.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'profile_screen.dart';
import 'user_content_detail_screen.dart';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF493028);
  final Color borderColor = const Color(0xFFFF806D);

  int _selectedIndex = 3;

  void _onNavigationTap(int index) {
    if (index == 3) return;

    Widget? destination;

    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;
      case 1:
        destination = const ScreeningScreen();
        break;
      case 2:
        destination = const DoctorScreen();
        break;
      case 4:
        destination = const ProfileScreen();
        break;
    }

    if (destination != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination!),
      );
    }
  }

  String _getDescription(AdminContentItem item) {
    // Prioritaskan ringkasan yang diisi admin saat membuat konten.
    final summary = item.summary.trim();
    if (summary.isNotEmpty) {
      return summary;
    }

    final content = item.content.trim();

    if (content.isEmpty) {
      return item.category.isNotEmpty
          ? item.category
          : 'Pelajari materi edukasi GERD.';
    }

    final firstParagraph = content
        .split('\n')
        .map((line) => line.trim())
        .firstWhere(
          (line) => line.isNotEmpty,
          orElse: () => '',
        );

    if (firstParagraph.isEmpty) {
      return 'Pelajari materi edukasi GERD.';
    }

    return firstParagraph;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Edukasi GERD',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<AdminContentItem>>(
                stream: AdminContentService.getContentsStream('edukasi'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA9583C),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 42,
                              color: Color(0xFFB9543A),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Edukasi gagal dimuat.',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Periksa koneksi dan aturan akses Firestore.\n'
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                color: Color(0xFF6B5147),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 48,
                              color: Color(0xFFB9543A),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada konten edukasi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF493C37),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return _buildEducationCard(
                        item: item,
                        description: _getDescription(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  Widget _buildEducationCard({
    required AdminContentItem item,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserContentDetailScreen(item: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 130,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9D9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                // Mendukung base64 (hasil simpan admin) / URL / asset
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: StomachyCoverImage(
                    imageSrc: item.imageAsset,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.menu_book_rounded,
                    fallbackIconSize: 38,
                    fallbackColor: const Color(0xFFB9543A),
                    fallbackBackgroundColor: const Color(0xFFFFE9D9),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      height: 1.25,
                      color: Color(0xFF39302C),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 5, right: 14),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}