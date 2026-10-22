import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';

import 'admin_content_detail_screen.dart';

class AdminManageEdukasiScreen extends StatefulWidget {
  const AdminManageEdukasiScreen({super.key});

  @override
  State<AdminManageEdukasiScreen> createState() =>
      _AdminManageEdukasiScreenState();
}

class _AdminManageEdukasiScreenState extends State<AdminManageEdukasiScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);

  static const Color headingDark = Color(0xFF251814);

  static const String contentType = 'edukasi';
  static const String defaultCategory = 'Materi Dasar';
  static const String defaultImageAsset = 'assets/images/edukasi_gerd.png';

    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _categoryController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();
    final TextEditingController _summaryController = TextEditingController();
    final TextEditingController _searchController = TextEditingController();

    final List<_EducationSectionDraft> _sections = [];

  AdminContentItem? _editingItem;
  bool _isSaving = false;


  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _contentController.dispose();
    _summaryController.dispose();

    for (final section in _sections) {
      section.dispose();
    }

    super.dispose();
  }

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
              _buildHeader('Kelola Edukasi'),
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

  Widget _buildAddButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showContentForm(editItem: null),
      backgroundColor: const Color(0xFFA9583C),
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Tambah Edukasi',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        cursorColor: const Color(0xFFB05039),
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Cari judul atau kategori edukasi...',
          hintStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB8B0AC),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFFB8B0AC),
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFFB8B0AC),
                  ),
                ),
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

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
            return _buildSearchEmptyState();
          }
          return _buildEmptyState();
        }

        return Column(
          children: [
            for (int i = 0; i < filteredItems.length; i++) ...[
              _buildContentCard(filteredItems[i]),
              if (i != filteredItems.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSearchEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 45, color: Color(0xFFB9543A)),
          SizedBox(height: 12),
          Text(
            'Konten tidak ditemukan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF493C37),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Coba kata kunci lain.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: Color(0xFF6B5147),
            ),
          ),
        ],
      ),
    );
  }

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
              color: Colors.black.withValues(alpha: 0.08),
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
                            Icons.article_outlined,
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


    void _showContentForm({required AdminContentItem? editItem}) {
    _editingItem = editItem;

    for (final section in _sections) {
        section.dispose();
    }
    _sections.clear();

    if (editItem != null) {
        _titleController.text = editItem.title;
        _categoryController.text = editItem.category;
        _contentController.text = editItem.content;
        _summaryController.text = editItem.summary;

        for (final section in editItem.sections) {
        final rawPoints = section['points'];
        final points = rawPoints is List
            ? rawPoints.map((point) => point.toString()).toList()
            : <String>[];

        _sections.add(
            _EducationSectionDraft(
            title: section['title']?.toString() ?? '',
            points: points.isEmpty ? [''] : points,
            ),
        );
        }

        // Konten lama yang belum memiliki sections tetap bisa diedit.
        if (_sections.isEmpty && editItem.content.trim().isNotEmpty) {
        _sections.add(
            _EducationSectionDraft(
            title: 'Materi',
            points: [editItem.content],
            ),
        );
        }
    } else {
        _titleController.clear();
        _categoryController.text = defaultCategory;
        _contentController.clear();
        _summaryController.clear();
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext sheetContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
            Widget fieldLabel(String text) {
                return Text(
                text,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF493C37),
                ),
                );
            }

            Widget textField({
                required TextEditingController controller,
                required String hint,
                int maxLines = 1,
            }) {
                return TextField(
                controller: controller,
                maxLines: maxLines,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(hint),
                );
            }

            return Padding(
                padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22),
                    ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SingleChildScrollView(
                    child: Column(
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
                            ? 'Tambah Edukasi'
                            : 'Edit Edukasi',
                        style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF251814),
                        ),
                        ),
                        const SizedBox(height: 16),

                        fieldLabel('Kategori'),
                        const SizedBox(height: 6),
                        textField(
                        controller: _categoryController,
                        hint: 'Contoh: Materi Dasar',
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Judul Edukasi'),
                        const SizedBox(height: 6),
                        textField(
                        controller: _titleController,
                        hint: 'Contoh: Apa Itu GERD?',
                        maxLines: 2,
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Ringkasan / Deskripsi Pembuka'),
                        const SizedBox(height: 6),
                        textField(
                        controller: _summaryController,
                        hint: 'Tulis pengantar singkat materi...',
                        maxLines: 4,
                        ),
                        const SizedBox(height: 20),

                        Row(
                        children: [
                            Expanded(
                            child: fieldLabel('Bagian Materi'),
                            ),
                            TextButton.icon(
                            onPressed: () {
                                setSheetState(() {
                                _sections.add(_EducationSectionDraft());
                                });
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Tambah Bagian'),
                            style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFB05039),
                            ),
                            ),
                        ],
                        ),
                        const SizedBox(height: 8),

                        if (_sections.isEmpty)
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EF),
                            borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                            'Belum ada bagian materi. Tekan "Tambah Bagian" untuk mulai.',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                color: Color(0xFF6B5147),
                            ),
                            ),
                        ),

                        for (int i = 0; i < _sections.length; i++) ...[
                        Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFF0DCD1),
                            ),
                            ),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                children: [
                                    Expanded(
                                    child: Text(
                                        'Bagian ${i + 1}',
                                        style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF493C37),
                                        ),
                                    ),
                                    ),
                                    IconButton(
                                    tooltip: 'Hapus bagian',
                                    onPressed: () {
                                        setSheetState(() {
                                        _sections.removeAt(i).dispose();
                                        });
                                    },
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFB05039),
                                        size: 20,
                                    ),
                                    ),
                                ],
                                ),
                                const SizedBox(height: 6),
                                fieldLabel('Judul Bagian'),
                                const SizedBox(height: 6),
                                textField(
                                controller: _sections[i].titleController,
                                hint: 'Contoh: Gejala GERD',
                                ),
                                const SizedBox(height: 14),

                                fieldLabel('Poin Materi'),
                                const SizedBox(height: 8),

                                for (
                                int j = 0;
                                j < _sections[i].pointControllers.length;
                                j++
                                ) ...[
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    Expanded(
                                        child: textField(
                                        controller:
                                            _sections[i].pointControllers[j],
                                        hint: 'Tulis poin materi...',
                                        maxLines: 3,
                                        ),
                                    ),
                                    IconButton(
                                        tooltip: 'Hapus poin',
                                        onPressed: () {
                                        setSheetState(() {
                                            final points =
                                                _sections[i].pointControllers;

                                            if (points.length > 1) {
                                            points.removeAt(j).dispose();
                                            } else {
                                            points.first.clear();
                                            }
                                        });
                                        },
                                        icon: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        color: Color(0xFFB05039),
                                        size: 20,
                                        ),
                                    ),
                                    ],
                                ),
                                const SizedBox(height: 8),
                                ],

                                Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                    onPressed: () {
                                    setSheetState(() {
                                        _sections[i]
                                            .pointControllers
                                            .add(TextEditingController());
                                    });
                                    },
                                    icon: const Icon(
                                    Icons.add_rounded,
                                    size: 17,
                                    ),
                                    label: const Text('Tambah Poin'),
                                    style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFB05039),
                                    ),
                                ),
                                ),
                            ],
                            ),
                        ),
                        ],

                        const SizedBox(height: 8),
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
                                        ? 'Simpan Edukasi'
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


    Future<void> _submitContent() async {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim();
    final summary = _summaryController.text.trim();

    final sections = _sections
        .map((section) {
            final points = section.pointControllers
                .map((controller) => controller.text.trim())
                .where((point) => point.isNotEmpty)
                .toList();

            return <String, dynamic>{
            'title': section.titleController.text.trim(),
            'points': points,
            };
        })
        .where(
            (section) =>
                (section['title'] as String).isNotEmpty ||
                (section['points'] as List).isNotEmpty,
        )
        .toList();

    // Tetap simpan content agar kompatibel dengan konten lama.
    final content = sections
        .map((section) {
            final sectionTitle = section['title'] as String;
            final points = section['points'] as List;

            return [
            if (sectionTitle.isNotEmpty) sectionTitle,
            ...points.map((point) => '• $point'),
            ].join('\n');
        })
        .where((text) => text.isNotEmpty)
        .join('\n\n');

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

    if (summary.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Ringkasan edukasi tidak boleh kosong.'),
        ),
        );
        return;
    }

    if (sections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Tambahkan minimal satu bagian materi.'),
        ),
        );
        return;
    }

    for (final section in sections) {
        if ((section['title'] as String).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Setiap bagian materi harus memiliki judul.'),
            ),
        );
        return;
        }

        if ((section['points'] as List).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Setiap bagian harus memiliki minimal satu poin.'),
            ),
        );
        return;
        }
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
            summary: summary,
            sections: sections,
        );
        } else {
        await AdminContentService.addContent(
            title: title,
            category: category,
            type: contentType,
            imageAsset: imageAsset,
            content: content,
            summary: summary,
            sections: sections,
        );
        }

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
            _editingItem == null
                ? 'Edukasi berhasil ditambahkan!'
                : 'Perubahan edukasi berhasil disimpan!',
            ),
        ),
        );
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

  void _showDeleteConfirmation(AdminContentItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
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
          Icon(Icons.article_outlined, size: 45, color: Color(0xFFB9543A)),
          SizedBox(height: 12),
          Text(
            'Belum ada konten edukasi',
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


class _EducationSectionDraft {
  final TextEditingController titleController;
  final List<TextEditingController> pointControllers;

  _EducationSectionDraft({
    String title = '',
    List<String> points = const [''],
  })  : titleController = TextEditingController(text: title),
        pointControllers = points
            .map((point) => TextEditingController(text: point))
            .toList();

  void dispose() {
    titleController.dispose();

    for (final controller in pointControllers) {
      controller.dispose();
    }
  }
}
