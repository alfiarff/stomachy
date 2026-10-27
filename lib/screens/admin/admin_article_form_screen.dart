import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/admin_content_service.dart';
import '../../widgets/stomachy_cover_image.dart';

// ===============================================================
// FORM TAMBAH / EDIT ARTIKEL (ADMIN)
// Full-screen + card putih per bagian — pola sama persis dengan
// form Edukasi / Makanan / Olahraga.
// ===============================================================

class AdminArticleFormScreen extends StatefulWidget {
  // Kirim null untuk mode TAMBAH,
  // atau kirim artikel yang mau diedit untuk mode EDIT.
  final AdminArticle? article;

  const AdminArticleFormScreen({super.key, this.article});

  @override
  State<AdminArticleFormScreen> createState() =>
      _AdminArticleFormScreenState();
}

class _AdminArticleFormScreenState extends State<AdminArticleFormScreen> {
  // Batas aman base64 (di bawah limit dokumen Firestore 1MB)
  static const int maxBase64Length = 900000;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final List<_ArticleSection> _sections = [];

  String _imageAsset = 'assets/images/artikel_tidur.png';
  bool _hasCustomCover = false;
  bool _isPublished = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final article = widget.article;

    if (article != null) {
      _titleController.text = article.title;
      _summaryController.text = article.summary;
      _categoryController.text = article.category;
      _imageAsset = article.imageAsset;
      _hasCustomCover = article.imageAsset.startsWith('data:image');
      _isPublished = article.isPublished;
      _sections.addAll(_parseContentToSections(article.content));
    } else {
      _sections.add(_ArticleSection());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _categoryController.dispose();
    for (final section in _sections) {
      section.dispose();
    }
    super.dispose();
  }

  // =============================================================
  // KONVERSI CONTENT (TEKS) <-> BAGIAN (FORM)
  // =============================================================

  // Konten lama dipecah jadi bagian-bagian agar bisa diedit di form.
  // Baris HURUF KAPITAL dianggap judul bagian, '- teks' dianggap poin,
  // teks biasa dianggap paragraf (bagian tanpa judul).
  List<_ArticleSection> _parseContentToSections(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return [_ArticleSection()];

    final sections = <_ArticleSection>[];
    final blocks = trimmed.split('\n\n');

    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      final first = lines.first;
      final isHeading = first.length > 3 &&
          first.toUpperCase() == first &&
          !first.startsWith('-') &&
          !first.startsWith('•') &&
          !RegExp(r'^\d+\.').hasMatch(first);

      if (isHeading) {
        final points = lines
            .skip(1)
            .map((line) => line.replaceFirst(RegExp(r'^[-•]\s*'), ''))
            .where((line) => line.isNotEmpty)
            .toList();
        sections.add(_ArticleSection(
          heading: first,
          points: points.isEmpty ? [''] : points,
        ));
      } else {
        final points = lines
            .map((line) => line.replaceFirst(RegExp(r'^[-•]\s*'), ''))
            .where((line) => line.isNotEmpty)
            .toList();
        sections.add(_ArticleSection(
          heading: '',
          points: points.isEmpty ? [''] : points,
        ));
      }
    }

    return sections.isEmpty ? [_ArticleSection()] : sections;
  }

  // Bagian-bagian digabung lagi jadi satu teks `content` untuk Firestore.
  // Hasilnya kompatibel dengan parser detail artikel yang sudah ada:
  // judul bagian -> baris HURUF KAPITAL, poin -> '- poin'.
  String _flattenSections() {
    final blocks = <String>[];

    for (final section in _sections) {
      final heading = section.headingController.text.trim();
      final points = section.pointControllers
          .map((controller) => controller.text.trim())
          .where((point) => point.isNotEmpty)
          .toList();

      if (heading.isEmpty && points.isEmpty) continue;

      final lines = <String>[];
      if (heading.isNotEmpty) lines.add(heading.toUpperCase());
      for (final point in points) {
        lines.add(heading.isNotEmpty ? '- $point' : point);
      }
      blocks.add(lines.join('\n'));
    }

    return blocks.join('\n\n');
  }

  // =============================================================
  // PILIH & CROP GAMBAR SAMPUL (BASE64 — TANPA STORAGE)
  // =============================================================

  Future<void> _pickCoverImage() async {
    if (_isSubmitting) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        maxWidth: 1080,
        maxHeight: 608,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Gambar Sampul',
            toolbarColor: const Color(0xFFA9583C),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFFA9583C),
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Sesuaikan Gambar Sampul',
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (cropped == null) return;

      final bytes = await File(cropped.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      if (base64Image.length > maxBase64Length) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content:
                Text('Gambar terlalu besar. Coba pilih gambar yang lebih kecil.'),
          ),
        );
        return;
      }

      setState(() {
        _imageAsset = 'data:image/jpeg;base64,$base64Image';
        _hasCustomCover = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Gagal memuat gambar: $e'),
        ),
      );
    }
  }

  // =============================================================
  // SIMPAN
  // =============================================================

  Future<void> _submitArticle() async {
    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    final category = _categoryController.text.trim();
    final content = _flattenSections();

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

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Di-capture SEBELUM pop agar tidak pakai context yang sudah mati.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      if (widget.article != null) {
        await AdminContentService.updateArticle(
          id: widget.article!.id,
          title: title,
          summary: summary,
          content: content,
          imageAsset: _imageAsset,
          isPublished: _isPublished,
          category: category,
        );

        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Perubahan artikel berhasil disimpan!'),
          ),
        );
      } else {
        await AdminContentService.addArticle(
          title: title,
          summary: summary,
          content: content,
          imageAsset: _imageAsset,
          isPublished: _isPublished,
          category: category,
        );

        navigator.pop();
        messenger.showSnackBar(
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
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Gagal menyimpan: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCoverCard(),
                    const SizedBox(height: 14),
                    _buildInfoCard(),
                    const SizedBox(height: 14),
                    _buildSectionsCard(),
                    const SizedBox(height: 14),
                    _buildPublishCard(),
                    const SizedBox(height: 20),
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
  // HEADER
  // =============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: SizedBox(
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
                  widget.article == null ? 'Tambah Artikel' : 'Edit Artikel',
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
      ),
    );
  }

  // =============================================================
  // CARD DASAR (pola sama dengan form edukasi/makanan/olahraga)
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
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7D8),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: const Color(0xFFB9543A)),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171310),
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
  // CARD 1: GAMBAR SAMPUL
  // =============================================================

  Widget _buildCoverCard() {
    return _buildFormCard(
      title: 'Gambar Sampul',
      icon: Icons.image_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickCoverImage,
            child: Container(
              width: double.infinity,
              height: 175,
              decoration: BoxDecoration(
                color: const Color(0xFFFBEFE6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: StomachyCoverImage(
                  imageSrc: _imageAsset,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.article_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _hasCustomCover
                    ? Icons.check_circle_rounded
                    : Icons.touch_app_rounded,
                size: 15,
                color: _hasCustomCover
                    ? const Color(0xFF2E7D42)
                    : const Color(0xFF9B8880),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _hasCustomCover
                      ? 'Gambar sampul siap. Ketuk gambar untuk mengganti.'
                      : 'Ketuk gambar untuk pilih sampul (otomatis dipotong rasio 16:9).',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: Color(0xFF9B8880),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CARD 2: INFORMASI ARTIKEL
  // =============================================================

  Widget _buildInfoCard() {
    return _buildFormCard(
      title: 'Informasi Artikel',
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Kategori'),
          const SizedBox(height: 6),
          TextField(
            controller: _categoryController,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration('Contoh: Saluran Cerna, Tips Makan'),
          ),
          const SizedBox(height: 14),
          _fieldLabel('Judul Artikel'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              'Contoh: Waspadai GERD: Bukan Sekadar Asam Lambung Naik',
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('Ringkasan'),
          const SizedBox(height: 6),
          TextField(
            controller: _summaryController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration('Tulis ringkasan singkat artikel...'),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CARD 3: ISI ARTIKEL (BAGIAN + POIN)
  // =============================================================

  Widget _buildSectionsCard() {
    return _buildFormCard(
      title: 'Isi Artikel',
      icon: Icons.notes_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tulis isi artikel per bagian. Judul bagian akan tampil sebagai sub-judul (huruf kapital) di halaman artikel.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: Color(0xFF9B8880),
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _sections.length; i++) ...[
            _buildSectionBox(i),
            if (i != _sections.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _sections.add(_ArticleSection());
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
                foregroundColor: const Color(0xFFA9583C),
                side: const BorderSide(color: Color(0xFFA9583C), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBox(int index) {
    final section = _sections[index];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFE6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0DCD1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bagian ${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB9543A),
                  ),
                ),
              ),
              if (_sections.length > 1)
                GestureDetector(
                  onTap: () => _removeSection(index),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFB9543A),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: section.headingController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              'Judul bagian, misal: Cara Mencegah Kambuh',
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          for (int j = 0; j < section.pointControllers.length; j++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: section.pointControllers[j],
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        'Tulis isi bagian atau poin di sini...',
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  if (section.pointControllers.length > 1) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          section.removePoint(j);
                        });
                      },
                      child: Icon(
                        Icons.close_rounded,
                        size: 17,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  section.addPoint();
                });
              },
              icon: const Icon(Icons.add_rounded, size: 15),
              label: const Text(
                'Tambah Poin',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB9543A),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeSection(int index) {
    final removed = _sections.removeAt(index);
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
    setState(() {});
  }

  // =============================================================
  // CARD 4: PUBLIKASI
  // =============================================================

  Widget _buildPublishCard() {
    return _buildFormCard(
      title: 'Publikasi',
      icon: Icons.campaign_rounded,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Tayangkan Sekarang',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF251814),
              ),
            ),
          ),
          Switch(
            value: _isPublished,
            activeColor: const Color(0xFFA9583C),
            onChanged: (value) {
              setState(() {
                _isPublished = value;
              });
            },
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
      height: 46,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitArticle,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA9583C),
          foregroundColor: Colors.white,
          elevation: 3,
          disabledBackgroundColor: const Color(0xFFA9583C).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
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
                widget.article == null ? 'Simpan Artikel' : 'Simpan Perubahan',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  // =============================================================
  // HELPER INPUT
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
      hintStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        color: Color(0xFFB6A8A2),
      ),
      filled: true,
      fillColor: fillColor ?? const Color(0xFFFFF5EF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ===============================================================
// MODEL BANTU: satu bagian isi artikel (judul + poin-poin)
// ===============================================================

class _ArticleSection {
  final TextEditingController headingController;
  final List<TextEditingController> pointControllers;

  _ArticleSection({String heading = '', List<String> points = const ['']})
      : headingController = TextEditingController(text: heading),
        pointControllers = [
          for (final point in points) TextEditingController(text: point),
        ];

  void addPoint() {
    pointControllers.add(TextEditingController());
  }

  void removePoint(int index) {
    final removed = pointControllers.removeAt(index);
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
    if (pointControllers.isEmpty) {
      pointControllers.add(TextEditingController());
    }
  }

  void dispose() {
    headingController.dispose();
    for (final controller in pointControllers) {
      controller.dispose();
    }
  }
}