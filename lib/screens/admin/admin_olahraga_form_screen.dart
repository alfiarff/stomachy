import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';
import '../../widgets/stomachy_cover_image.dart';

// ===============================================================
// FORM TAMBAH / EDIT REKOMENDASI OLAHRAGA (FULL SCREEN - VERSI CARD)
// - Struktur & gaya sama dengan form edukasi & makanan
// - Gambar sampul: galeri -> crop 16:9 -> base64 -> field imageAsset
// - type = 'olahraga' (dikunci di file ini)
// ===============================================================

class AdminOlahragaFormScreen extends StatefulWidget {
  final AdminContentItem? editItem;

  const AdminOlahragaFormScreen({super.key, this.editItem});

  @override
  State<AdminOlahragaFormScreen> createState() =>
      _AdminOlahragaFormScreenState();
}

class _AdminOlahragaFormScreenState extends State<AdminOlahragaFormScreen> {
  static const String defaultCategory = 'Relaksasi';

  // TODO: ganti ke asset khusus olahraga kalau sudah ada,
  // mis. 'assets/images/olahraga.png'
  static const String defaultImageAsset = 'assets/images/edukasi_gerd.png';
  // Batas aman base64 agar ukuran dokumen Firestore tetap < 1MB.
  static const int maxBase64Length = 900000;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final List<_OlahragaSectionDraft> _sections = [];

  Uint8List? _selectedImageBytes;
  String? _existingImage; // asset path / url / base64 lama saat edit
  bool _isSubmitting = false;

  bool get _isEditing => widget.editItem != null;

  @override
  void initState() {
    super.initState();

    final item = widget.editItem;
    if (item != null) {
      _titleController.text = item.title;
      _categoryController.text = item.category;
      _summaryController.text = item.summary;
      _existingImage = item.imageAsset;

      for (final section in item.sections) {
        final map = Map<String, dynamic>.from(section as Map);
        final rawPoints = map['points'];
        final points = rawPoints is List
            ? rawPoints.map((point) => point.toString()).toList()
            : <String>[];

        _sections.add(
          _OlahragaSectionDraft(
            title: map['title']?.toString() ?? '',
            points: points.isEmpty ? [''] : points,
          ),
        );
      }

      // Konten lama yang belum punya sections tetap bisa diedit.
      if (_sections.isEmpty && item.content.trim().isNotEmpty) {
        _sections.add(
          _OlahragaSectionDraft(
            title: 'Rekomendasi',
            points: [item.content],
          ),
        );
      }
    } else {
      _categoryController.text = defaultCategory;
      _sections.add(_OlahragaSectionDraft());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _summaryController.dispose();

    for (final section in _sections) {
      section.dispose();
    }

    super.dispose();
  }

  // =============================================================
  // HEADER
  // =============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          GestureDetector(
            onTap: _isSubmitting ? null : () => Navigator.pop(context),
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
                _isEditing ? 'Edit Olahraga' : 'Tambah Olahraga',
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
  // CARD WRAPPER
  // =============================================================

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7D8),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: const Color(0xFFB05039),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171310),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // =============================================================
  // GAMBAR SAMPUL
  // =============================================================

  Future<void> _pickCover() async {
    if (_isSubmitting) return;

    try {
      final bytes = await StomachyCoverImage.pickAndCropCover();
      if (bytes == null || !mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Gagal memproses gambar: $e'),
        ),
      );
    }
  }

  Widget _buildCoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickCover,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0DCD1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildCoverPreview(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _selectedImageBytes == null
                  ? Icons.touch_app_rounded
                  : Icons.check_circle_rounded,
              size: 13,
              color: _selectedImageBytes == null
                  ? const Color(0xFF999999)
                  : const Color(0xFF2E7D42),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _selectedImageBytes == null
                    ? 'Ketuk gambar untuk memilih / mengganti sampul (rasio 16:9)'
                    : 'Gambar siap disimpan. Ketuk gambar untuk mengganti.',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverPreview() {
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return StomachyCoverImage(
      imageSrc: _existingImage,
      fit: BoxFit.cover,
      width: double.infinity,
      fallbackIcon: Icons.directions_run_rounded,
      fallbackIconSize: 42,
      fallbackColor: const Color(0xFFB05039),
      fallbackBackgroundColor: const Color(0xFFFFF5EF),
    );
  }

  // =============================================================
  // FIELD HELPERS
  // =============================================================

  Widget _fieldLabel(String text) {
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

  InputDecoration _inputDecoration(String hint, {Color? fillColor}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFB6A8A2)),
      filled: true,
      fillColor: fillColor ?? const Color(0xFFFFF5EF),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    Color? fillColor,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF493C37),
      ),
      cursorColor: const Color(0xFFB05039),
      decoration: _inputDecoration(hint, fillColor: fillColor),
    );
  }

  // =============================================================
  // CARD 2: INFORMASI OLAHRAGA
  // =============================================================

  Widget _buildInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Kategori'),
        const SizedBox(height: 6),
        _textField(
          controller: _categoryController,
          hint: 'Contoh: Relaksasi',
        ),
        const SizedBox(height: 14),
        _fieldLabel('Judul'),
        const SizedBox(height: 6),
        _textField(
          controller: _titleController,
          hint: 'Contoh: Peregangan Pagi yang Aman',
          maxLines: 2,
        ),
        const SizedBox(height: 14),
        _fieldLabel('Ringkasan / Deskripsi Pembuka'),
        const SizedBox(height: 6),
        _textField(
          controller: _summaryController,
          hint: 'Tulis pengantar singkat rekomendasi...',
          maxLines: 4,
        ),
      ],
    );
  }

  // =============================================================
  // VALIDASI + SUBMIT
  // =============================================================

  String? _validate() {
    if (_titleController.text.trim().isEmpty) {
      return 'Judul tidak boleh kosong.';
    }
    if (_summaryController.text.trim().isEmpty) {
      return 'Ringkasan tidak boleh kosong.';
    }
    if (_sections.isEmpty) {
      return 'Tambahkan minimal satu bagian rekomendasi.';
    }

    for (int i = 0; i < _sections.length; i++) {
      if (_sections[i].titleController.text.trim().isEmpty) {
        return 'Bagian ${i + 1} belum memiliki judul.';
      }
      final hasPoint = _sections[i]
          .pointControllers
          .any((controller) => controller.text.trim().isNotEmpty);
      if (!hasPoint) {
        return 'Bagian ${i + 1} harus memiliki minimal satu poin.';
      }
    }

    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(error),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Di-capture SEBELUM pop agar snackbar tetap bisa muncul
    // setelah halaman form ditutup.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // 1. Siapkan gambar sampul (base64 / lama / default)
      String imageAsset;
      if (_selectedImageBytes != null) {
        final base64Image = base64Encode(_selectedImageBytes!);

        if (base64Image.length > maxBase64Length) {
          throw Exception(
            'Ukuran gambar terlalu besar. Coba pilih gambar yang lebih kecil.',
          );
        }

        imageAsset = base64Image;
      } else if (_existingImage != null &&
          _existingImage!.trim().isNotEmpty) {
        imageAsset = _existingImage!;
      } else {
        imageAsset = defaultImageAsset;
      }

      // 2. Rakit bagian rekomendasi
      final sections = <Map<String, dynamic>>[];
      final contentBlocks = <String>[];

      for (final section in _sections) {
        final sectionTitle = section.titleController.text.trim();
        final points = section.pointControllers
            .map((controller) => controller.text.trim())
            .where((point) => point.isNotEmpty)
            .toList();

        if (sectionTitle.isEmpty && points.isEmpty) continue;

        sections.add({'title': sectionTitle, 'points': points});

        // Versi teks polos agar konten tetap tampil di tampilan lama
        // (heading = HURUF BESAR, bullet = "- ").
        contentBlocks.add(
          [
            if (sectionTitle.isNotEmpty) sectionTitle.toUpperCase(),
            ...points.map((point) => '- $point'),
          ].join('\n'),
        );
      }

      final content = contentBlocks
          .where((text) => text.isNotEmpty)
          .join('\n\n');

      // 3. Simpan ke Firestore
      if (_isEditing) {
        await AdminContentService.updateContent(
          id: widget.editItem!.id,
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          type: 'olahraga',
          imageAsset: imageAsset,
          content: content,
          summary: _summaryController.text.trim(),
          sections: sections,
        );
      } else {
        await AdminContentService.addContent(
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          type: 'olahraga',
          imageAsset: imageAsset,
          content: content,
          summary: _summaryController.text.trim(),
          sections: sections,
        );
      }

      // 4. Tutup form + pesan sukses
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D42),
          content: Text(
            _isEditing
                ? 'Perubahan olahraga berhasil disimpan!'
                : 'Olahraga berhasil ditambahkan!',
          ),
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB9543A),
          duration: const Duration(seconds: 5),
          content: Text('Gagal menyimpan olahraga: $e'),
        ),
      );
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: _buildHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormCard(
                      title: 'Gambar Sampul',
                      icon: Icons.image_rounded,
                      child: _buildCoverSection(),
                    ),
                    const SizedBox(height: 16),
                    _buildFormCard(
                      title: 'Informasi Olahraga',
                      icon: Icons.edit_note_rounded,
                      child: _buildInfoFields(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionsCard(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // CARD 3: BAGIAN REKOMENDASI
  // =============================================================

  Widget _buildSectionsCard() {
    return _buildFormCard(
      title: 'Bagian Rekomendasi',
      icon: Icons.directions_run_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _sections.length; i++) _buildSectionBox(i),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _sections.add(_OlahragaSectionDraft());
                      });
                    },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Tambah Bagian',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB05039),
                side: const BorderSide(
                  color: Color(0xFFB05039),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBox(int i) {
    return Container(
      margin: EdgeInsets.only(
        bottom: i == _sections.length - 1 ? 12 : 14,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFE6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0DCD1)),
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
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
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
          _fieldLabel('Judul Bagian'),
          const SizedBox(height: 6),
          _textField(
            controller: _sections[i].titleController,
            hint: 'Contoh: Gerakan Peregangan',
            fillColor: Colors.white,
          ),
          const SizedBox(height: 14),
          _fieldLabel('Poin Rekomendasi'),
          const SizedBox(height: 8),

          for (int j = 0; j < _sections[i].pointControllers.length; j++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _textField(
                    controller: _sections[i].pointControllers[j],
                    hint: 'Tulis poin rekomendasi...',
                    maxLines: 3,
                    fillColor: Colors.white,
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus poin',
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            final points = _sections[i].pointControllers;
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
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _sections[i].pointControllers.add(
                          TextEditingController(),
                        );
                      });
                    },
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('Tambah Poin'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB05039),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // TOMBOL SIMPAN
  // =============================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA9583C),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFFA9583C).withOpacity(0.6),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isEditing ? 'Simpan Perubahan' : 'Simpan Olahraga',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _OlahragaSectionDraft {
  final TextEditingController titleController;
  final List<TextEditingController> pointControllers;

  _OlahragaSectionDraft({
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