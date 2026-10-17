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
  State<AdminArticleScreen> createState() => _AdminArticleScreenState();
}

class _AdminArticleScreenState extends State<AdminArticleScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);

  static const Color headingDark = Color(0xFF251814);
  static const Color bodyText = Color(0xFF6B5147);

  // ===============================================================
  // CONTROLLER FORM ARTIKEL (DIPAKAI UNTUK TAMBAH & EDIT)
  // ===============================================================
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  bool _isPublished = true;

  // Menyimpan artikel yang sedang di-edit (null = mode tambah)
  AdminArticle? _editingArticle;

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
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 95),
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

                  if (i != articles.length - 1) const SizedBox(height: 14),
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
        onPressed: () => _showArticleForm(editArticle: null),
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
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                  article.isPublished ? 'Tayang Sekarang' : 'Draf',
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
              // ============== EDIT ==============
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () => _showArticleForm(editArticle: article),
              ),
              const SizedBox(width: 8),

              // ============== HAPUS ==============
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Hapus',
                onTap: () => _showDeleteConfirmation(article),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
  // FORM ARTIKEL (BOTTOM SHEET)
  //
  // Dipakai untuk TAMBAH dan EDIT.
  // - editArticle == null  → mode TAMBAH
  // - editArticle != null  → mode EDIT (form pre-isi)
  // ===============================================================

  void _showArticleForm({required AdminArticle? editArticle}) {
    // Simpan artikel yang sedang di-edit
    _editingArticle = editArticle;

    if (editArticle != null) {
      // Mode EDIT: pre-isi form dengan data artikel
      _titleController.text = editArticle.title;
      _summaryController.text = editArticle.summary;
      _isPublished = editArticle.isPublished;
    } else {
      // Mode TAMBAH: kosongkan form
      _titleController.clear();
      _summaryController.clear();
      _isPublished = true;
    }

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

                    // Judul form (dinamis: Tambah / Edit)
                    Text(
                      _editingArticle == null
                          ? 'Tambah Artikel Baru'
                          : 'Edit Artikel',
                      style: const TextStyle(
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
                        hintText:
                            'Contoh: Tips Tidur Nyenyak untuk Penderita GERD',
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
                        child: Text(
                          _editingArticle == null
                              ? 'Simpan Artikel'
                              : 'Simpan Perubahan',
                          style: const TextStyle(
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
  // SUBMIT (TAMBAH / EDIT ARTIKEL)
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

    // ----- SIMPAN / UPDATE -----
    setState(() {
      if (_editingArticle != null) {
        // Mode EDIT: cari artikel lama, ganti dengan yang baru
        final index =
            AdminContentService.articles.indexOf(_editingArticle!);

        if (index != -1) {
          AdminContentService.articles[index] = AdminArticle(
            title: title,
            summary: summary,
            // Gambar tetap pakai yang lama (belum ada fitur upload)
            imageAsset: _editingArticle!.imageAsset,
            isPublished: _isPublished,
          );
        }
      } else {
        // Mode TAMBAH: insert artikel baru di paling atas
        AdminContentService.articles.insert(
          0,
          AdminArticle(
            title: title,
            summary: summary,
            imageAsset: 'assets/images/artikel_tidur.png',
            isPublished: _isPublished,
          ),
        );
      }
    });

    // ----- TUTUP BOTTOM SHEET -----
    Navigator.pop(context);

    // ----- NOTIFIKASI -----
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          _editingArticle != null
              ? 'Perubahan artikel berhasil disimpan!'
              : (_isPublished
                  ? 'Artikel berhasil ditayangkan!'
                  : 'Artikel disimpan sebagai draf.'),
        ),
      ),
    );

    // Reset state editing
    _editingArticle = null;
  }

  // ===============================================================
  // KONFIRMASI HAPUS ARTIKEL
  // ===============================================================

  void _showDeleteConfirmation(AdminArticle article) {
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
                // Icon tempat sampah di tengah
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
                  'Hapus Artikel?',
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
                  'Apakah Anda yakin ingin menghapus artikel ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Color(0xFF493C37),
                  ),
                ),
                const SizedBox(height: 18),

                // Tombol: Tidak / Ya, Hapus
                Row(
                  children: [
                    // ===== TOMBOL TIDAK =====
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
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

                    // ===== TOMBOL YA, HAPUS =====
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              AdminContentService.articles.remove(article);
                            });

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('Artikel berhasil dihapus.'),
                              ),
                            );
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