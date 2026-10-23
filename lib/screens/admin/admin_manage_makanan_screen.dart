import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';
import '../../widgets/stomachy_cover_image.dart';

import 'admin_content_detail_screen.dart';
import 'admin_makanan_form_screen.dart';

// ===============================================================
// KELOLA REKOMENDASI MAKANAN (ADMIN)
//
// - List + cari + hapus konten makanan
// - Tambah/Edit -> AdminMakananFormScreen (full screen)
// - type = 'makanan' (dikunci di file ini)
// ===============================================================

class AdminManageMakananScreen extends StatefulWidget {
  const AdminManageMakananScreen({super.key});

  @override
  State<AdminManageMakananScreen> createState() =>
      _AdminManageMakananScreenState();
}

class _AdminManageMakananScreenState extends State<AdminManageMakananScreen> {
  static const String contentType = 'makanan';
  static const Color headingDark = Color(0xFF251814);

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
      floatingActionButton: _buildAddButton(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: _buildHeader('Kelola Makanan'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
              child: _buildSearchField(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 90),
                child: _buildContentList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // HEADER
  // =============================================================

  Widget _buildHeader(String title) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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

  // =============================================================
  // TOMBOL TAMBAH
  // =============================================================

  Widget _buildAddButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminMakananFormScreen(),
          ),
        );
      },
      backgroundColor: const Color(0xFFA9583C),
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Tambah Makanan',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // =============================================================
  // PENCARIAN
  // =============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'Cari makanan...',
        hintStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          color: Color(0xFF9B8880),
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFA9583C),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // =============================================================
  // DAFTAR KONTEN
  // =============================================================

  Widget _buildContentList() {
    return StreamBuilder<List<AdminContentItem>>(
      stream: AdminContentService.getContentsStream(contentType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final items = snapshot.data ?? [];
        final keyword = _searchController.text.trim().toLowerCase();

        final filteredItems = items.where((item) {
          return item.title.toLowerCase().contains(keyword) ||
              item.category.toLowerCase().contains(keyword);
        }).toList();

        if (filteredItems.isEmpty) {
          if (keyword.isNotEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 40,
                horizontal: 20,
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 45,
                    color: Color(0xFFB9543A),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Makanan tidak ditemukan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF493C37),
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildEmptyState();
        }

        return Column(
          children: [
            for (int i = 0; i < filteredItems.length; i++) ...[
              _buildContentCard(filteredItems[i]),
              if (i != filteredItems.length - 1)
                const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }

  // =============================================================
  // CONTENT CARD
  // =============================================================

  Widget _buildContentCard(AdminContentItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminContentDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.category.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0D7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9C6F1A),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: StomachyCoverImage(
                      imageSrc: item.imageAsset,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.restaurant_outlined,
                      fallbackIconSize: 28,
                      fallbackColor: const Color(0xFFB9543A),
                      fallbackBackgroundColor: const Color(0xFFFFE7D8),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: headingDark,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminMakananFormScreen(editItem: item),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 8),

                _buildActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus',
                  onTap: () => _showDeleteConfirmation(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEE5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFFB9543A)),

            const SizedBox(width: 5),

            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB9543A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // HAPUS KONTEN
  // =============================================================

  void _showDeleteConfirmation(AdminContentItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 45),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE7D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 32,
                    color: Color(0xFFB9543A),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Hapus Konten?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB9543A),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Apakah Anda yakin ingin menghapus konten ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF493C37),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: Color(0xFFB05039),
                              width: 0.9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Tidak',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB05039),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            try {
                              await AdminContentService.deleteContent(item.id);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Konten berhasil dihapus.'),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Gagal menghapus: $e'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB05039),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Ya, Hapus',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // STATE LOADING / ERROR / KOSONG
  // =============================================================

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFFA9583C)),
          SizedBox(height: 12),
          Text(
            'Memuat konten...',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Color(0xFF493C37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat konten',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF493C37),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: Color(0xFF776C67),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.restaurant_outlined, size: 45, color: Color(0xFFB9543A)),
          SizedBox(height: 12),
          Text(
            'Belum ada konten rekomendasi makanan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF493C37),
            ),
          ),
        ],
      ),
    );
  }
}