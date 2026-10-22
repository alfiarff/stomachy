import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';

import 'admin_content_detail_screen.dart';

// ===============================================================
// KELOLA REKOMENDASI OLAHRAGA (ADMIN)
//
// CRUD khusus konten rekomendasi olahraga.
// type = 'olahraga' (sudah dikunci di file ini)
// ===============================================================

class AdminManageOlahragaScreen extends StatefulWidget {
  const AdminManageOlahragaScreen({super.key});

  @override
  State<AdminManageOlahragaScreen> createState() =>
      _AdminManageOlahragaScreenState();
}

class _AdminManageOlahragaScreenState
    extends State<AdminManageOlahragaScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);

  static const Color headingDark = Color(0xFF251814);
  static const Color bodyText = Color(0xFF6B5147);

  // =============================================================
  // PENGATURAN KONTEN OLAHRAGA
  // =============================================================

  static const String contentType = 'olahraga';
  static const String defaultCategory = 'Relaksasi';

  // TODO: ganti ke asset khusus olahraga kalau sudah ada,
  // mis. 'assets/images/olahraga.png'
  static const String defaultImageAsset = 'assets/images/edukasi_gerd.png';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  AdminContentItem? _editingItem;
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // =============================================================
  // BUILD
  // =============================================================


    @override
    Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: _buildAddButton(),
        body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                _buildHeader('Kelola Olahraga'),
                const SizedBox(height: 18),
                _buildSearchField(),
                const SizedBox(height: 18),
                Expanded(
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 90),
                    child: _buildContentList(),
                ),
                ),
            ],
            ),
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


    Widget _buildSearchField() {
    return TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 13,
        color: headingDark,
        ),
        decoration: InputDecoration(
        hintText: 'Cari olahraga...',
        hintStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            color: Color(0xFFB6A8A2),
        ),
        prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFB9543A),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFFB9543A),
                ),
                onPressed: () {
                    _searchController.clear();
                    setState(() {});
                },
                )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
        ),
        ),
    );
    }


  // =============================================================
  // TOMBOL TAMBAH
  // =============================================================


    Widget _buildAddButton() {
    return FloatingActionButton.extended(
        onPressed: () => _showContentForm(editItem: null),
        backgroundColor: const Color(0xFFA9583C),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
        'Tambah Olahraga',
        style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w800,
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
                vertical: 35,
                horizontal: 20,
                ),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                children: [
                    Icon(
                    Icons.search_off_rounded,
                    size: 42,
                    color: Color(0xFFB9543A),
                    ),
                    SizedBox(height: 10),
                    Text(
                    'Olahraga tidak ditemukan',
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
                    child: Image.asset(
                      item.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFFFE7D8),
                          child: const Icon(
                            Icons.restaurant_outlined,
                            size: 28,
                            color: Color(0xFFB9543A),
                          ),
                        );
                      },
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
                  onTap: () => _showContentForm(editItem: item),
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
  // FORM TAMBAH / EDIT
  // =============================================================

  void _showContentForm({required AdminContentItem? editItem}) {
    _editingItem = editItem;

    if (editItem != null) {
      _titleController.text = editItem.title;
      _categoryController.text = editItem.category;
      _contentController.text = editItem.content;
    } else {
      _titleController.clear();
      _categoryController.text = defaultCategory;
      _contentController.clear();
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
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      Text(
                        _editingItem == null
                            ? 'Tambah Konten Baru'
                            : 'Edit Konten',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF251814),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF493C37),
                        ),
                      ),

                      const SizedBox(height: 6),

                      TextField(
                        controller: _categoryController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration('Contoh: Karbohidrat'),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Judul',
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
                        decoration: _inputDecoration(
                          'Contoh: Sarapan Aman untuk Penderita GERD',
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Isi Konten',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF493C37),
                        ),
                      ),

                      const SizedBox(height: 6),

                      TextField(
                        controller: _contentController,
                        maxLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          'Tulis isi lengkap konten di sini...',
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submitContent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA9583C),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _editingItem == null
                                      ? 'Simpan Konten'
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
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFB6A8A2)),
      filled: true,
      fillColor: const Color(0xFFFFF5EF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // =============================================================
  // SIMPAN KONTEN
  // =============================================================

  Future<void> _submitContent() async {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim();
    final content = _contentController.text.trim();

    // Saat edit -> pertahankan gambar lama konten.
    // Saat tambah baru -> pakai gambar default.
    final String imageAsset =
        (_editingItem != null && _editingItem!.imageAsset.isNotEmpty)
            ? _editingItem!.imageAsset
            : defaultImageAsset;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Judul tidak boleh kosong.'),
        ),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Isi konten tidak boleh kosong.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_editingItem != null) {
        await AdminContentService.updateContent(
          id: _editingItem!.id,
          title: title,
          category: category,
          type: contentType,
          imageAsset: imageAsset,
          content: content,
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Perubahan konten berhasil disimpan!'),
          ),
        );
      } else {
        await AdminContentService.addContent(
          title: title,
          category: category,
          type: contentType,
          imageAsset: imageAsset,
          content: content,
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Konten baru berhasil ditambahkan!'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Gagal menyimpan: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
            'Belum ada konten rekomendasi olahraga',
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