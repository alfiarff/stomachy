import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';
import '../../widgets/admin_bottom_navigation.dart';

import 'admin_home_screen.dart';
import 'admin_content_screen.dart';
import 'admin_profile_screen.dart';     

// ===============================================================
// KELOLA ARTIKEL (ADMIN)
// ===============================================================

class AdminArticleScreen extends StatefulWidget {
  const AdminArticleScreen({super.key});

  @override
  State<AdminArticleScreen> createState() =>
      _AdminArticleScreenState();
}

class _AdminArticleScreenState
    extends State<AdminArticleScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);

  static const Color headingDark = Color(0xFF251814);
  static const Color bodyText = Color(0xFF6B5147);

  // ===============================================================
  // CONTROLLER FORM TAMBAH ARTIKEL
  // ===============================================================
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  bool _isPublished = true;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == 1) {
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

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminContentScreen(),
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
    final articles = AdminContentService.articles;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            15,
            10,
            15,
            95,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader('Artikel'),

              const SizedBox(height: 18),

              _buildAddButton(),

              const SizedBox(height: 18),

              if (articles.isEmpty)
                _buildEmptyState()
              else
                for (int i = 0; i < articles.length; i++) ...[
                  _buildArticleCard(articles[i]),

                  if (i != articles.length - 1)
                    const SizedBox(height: 14),
                ],

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),

      bottomNavigationBar: AdminBottomNavigation(
        selectedIndex: 1,
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
  // TOMBOL TAMBAH
  // ===============================================================

  Widget _buildAddButton() {
  return SizedBox(
    width: double.infinity,
    height: 46,
    child: ElevatedButton.icon(
      onPressed: _showAddArticleForm,
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Fitur tambah artikel sedang dalam pengembangan.',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA9583C),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Tambah Artikel',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // ARTICLE CARD
  // ===============================================================

  Widget _buildArticleCard(AdminArticle article) {
    return Container(
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
          // ================================================
          // CHIP STATUS
          // ================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: article.isPublished
                  ? const Color(0xFFE5F3E8)
                  : const Color(0xFFFFF0D7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: article.isPublished
                        ? const Color(0xFF2E9E5B)
                        : const Color(0xFFEBA21D),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  article.isPublished
                      ? 'Tayang Sekarang'
                      : 'Draf',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: article.isPublished
                        ? const Color(0xFF2E7D4F)
                        : const Color(0xFF9C6F1A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ================================================
          // GAMBAR + TEKS
          // ================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 95,
                height: 95,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    article.imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) {
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                        color: headingDark,
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
                        fontWeight: FontWeight.w400,
                        color: bodyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ================================================
          // AKSI
          // ================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Fitur edit artikel sedang dalam pengembangan.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Hapus',
                onTap: () {
                  setState(() {
                    AdminContentService.articles
                        .remove(article);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Artikel dihapus.'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
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
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEE5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: const Color(0xFFB9543A),
            ),

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

  // ===============================================================
  // FORM TAMBAH ARTIKEL (BOTTOM SHEET)
  // ===============================================================

  void _showAddArticleForm() {
    // Reset form setiap kali dibuka
    _titleController.clear();
    _summaryController.clear();
    _isPublished = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar (garis kecil di atas sheet)
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0CBBE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Tambah Artikel Baru',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF251814),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==============================
                    // JUDUL
                    // ==============================
                    const Text(
                      'Judul Artikel',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF493C37),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Tips Tidur Nyenyak untuk Penderita GERD',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB6A8A2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFF5EF),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ==============================
                    // RINGKASAN
                    // ==============================
                    const Text(
                      'Ringkasan',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF493C37),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _summaryController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Tulis ringkasan singkat artikel...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB6A8A2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFF5EF),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ==============================
                    // STATUS TAYANG (SWITCH)
                    // ==============================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tayangkan Sekarang',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF251814),
                          ),
                        ),
                        Switch(
                          value: _isPublished,
                          activeColor: const Color(0xFFA9583C),
                          onChanged: (value) {
                            setSheetState(() {
                              _isPublished = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ==============================
                    // TOMBOL SIMPAN
                    // ==============================
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _submitArticle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA9583C),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                        ),
                        child: const Text(
                          'Simpan Artikel',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

    // ===============================================================
  // SUBMIT (SIMPAN) ARTIKEL BARU
  // ===============================================================

  void _submitArticle() {
    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();

    // ----- VALIDASI -----
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Judul artikel tidak boleh kosong.'),
        ),
      );
      return;
    }

    if (summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Ringkasan artikel tidak boleh kosong.'),
        ),
      );
      return;
    }

    // ----- SIMPAN KE LIST -----
    setState(() {
      AdminContentService.articles.insert(
        0, // insert ke urutan paling atas
        AdminArticle(
          title: title,
          summary: summary,
          // Sementara pakai asset default. Nanti bisa kamu ganti
          // dengan fitur upload gambar.
          imageAsset: 'assets/images/artikel_tidur.png',
          isPublished: _isPublished,
        ),
      );
    });

    // ----- TUTUP BOTTOM SHEET -----
    Navigator.pop(context);

    // ----- NOTIFIKASI -----
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          _isPublished
              ? 'Artikel berhasil ditayangkan!'
              : 'Artikel disimpan sebagai draf.',
        ),
      ),
    );
  }
  
  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 45,
            color: Color(0xFFB9543A),
          ),

          SizedBox(height: 12),

          Text(
            'Belum ada artikel',
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