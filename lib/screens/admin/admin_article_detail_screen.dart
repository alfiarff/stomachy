import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';

// ===============================================================
// DETAIL ARTIKEL (ADMIN) - TAMPILAN PROFESIONAL
// ===============================================================

class AdminArticleDetailScreen extends StatelessWidget {
  final AdminArticle article;

  const AdminArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(),
                    _buildArticleBody(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
                  size: 26,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Artikel Kesehatan',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 18,
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
  // HERO IMAGE
  // ===============================================================

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          article.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFFFE7D8),
              child: const Icon(
                Icons.article_outlined,
                size: 70,
                color: Color(0xFFB9543A),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================================================
  // BODY ARTIKEL
  // ===============================================================

  Widget _buildArticleBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KATEGORI BADGE
          if (article.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE7D8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFA9583C).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                article.category.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFA9583C),
                  letterSpacing: 0.8,
                ),
              ),
            ),

          if (article.category.isNotEmpty) const SizedBox(height: 12),

          // JUDUL
          Text(
            article.title,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF251814),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // INFO: STATUS + READING TIME
          Row(
            children: [
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: article.isPublished
                      ? const Color(0xFFE5F3E8)
                      : const Color(0xFFFFF0D7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: article.isPublished
                            ? const Color(0xFF2E9E5B)
                            : const Color(0xFFEBA21D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      article.isPublished ? 'Tayang' : 'Draf',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: article.isPublished
                            ? const Color(0xFF2E7D4F)
                            : const Color(0xFF9C6F1A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Reading time (estimasi dari content)
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                _estimateReadingTime(article.content),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // DIVIDER
          const Divider(
            color: Color(0xFFE0CBBE),
            thickness: 1,
            height: 1,
          ),

          const SizedBox(height: 18),

          // RINGKASAN (italic, sebagai intro)
          if (article.summary.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Color(0xFFA9583C),
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                article.summary,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF6B5147),
                  height: 1.5,
                ),
              ),
            ),

          if (article.summary.isNotEmpty) const SizedBox(height: 20),

          // ISI ARTIKEL
          _buildContentBody(article.content),
        ],
      ),
    );
  }

  // ===============================================================
  // CONTENT BODY - PARSE SEDERHANA (HURUF BESAR = SUBTITLE)
  // ===============================================================

  Widget _buildContentBody(String content) {
    if (content.isEmpty) {
      return const Text(
        'Artikel ini belum memiliki isi.',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          color: Color(0xFF6B5147),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Pecah per baris
    final lines = content.split('\n');
    List<Widget> contentWidgets = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        contentWidgets.add(const SizedBox(height: 10));
        continue;
      }

      // Deteksi heading: baris yang HURUF BESAR SEMUA (atau pakai ##)
      final isAllCaps = trimmed.toUpperCase() == trimmed &&
          trimmed.length > 3 &&
          !trimmed.contains(RegExp(r'[.]$')) &&
          !trimmed.startsWith('-') &&
          !trimmed.startsWith('•');

      // Deteksi list item
      final isList = trimmed.startsWith('-') || trimmed.startsWith('•');
      final isNumbered = RegExp(r'^\d+\.').hasMatch(trimmed);

      if (trimmed.startsWith('## ')) {
        // Heading ## 
        contentWidgets.add(_buildHeading(trimmed.substring(3)));
      } else if (isAllCaps && !isList && !isNumbered) {
        // Heading all caps
        contentWidgets.add(_buildHeading(trimmed));
      } else if (isList) {
        // Bullet list
        contentWidgets.add(_buildBullet(trimmed));
      } else if (isNumbered) {
        // Numbered list
        contentWidgets.add(_buildBullet(trimmed));
      } else {
        // Paragraph
        contentWidgets.add(_buildParagraph(trimmed));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF251814),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    final cleanText = text.replaceFirst(RegExp(r'^[-•]\s*'), '');
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 5,
              color: Color(0xFFA9583C),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cleanText,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Color(0xFF493C37),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          color: Color(0xFF493C37),
          height: 1.6,
        ),
      ),
    );
  }

  // ===============================================================
  // ESTIMASI WAKTU BACA
  // ===============================================================

  String _estimateReadingTime(String content) {
    if (content.isEmpty) return '0 menit baca';
    final words = content.split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return '$minutes menit baca';
  }
}