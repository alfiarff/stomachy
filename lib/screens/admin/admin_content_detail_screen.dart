import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';

// ===============================================================
// DETAIL KONTEN (ADMIN) - EDUKASI / MAKANAN / OLAHRAGA
// ===============================================================

class AdminContentDetailScreen extends StatelessWidget {
  final AdminContentItem item;

  const AdminContentDetailScreen({super.key, required this.item});

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
                  children: [_buildHeroImage(), _buildContentBody()],
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
                  _getHeaderTitle(),
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

  String _getHeaderTitle() {
    switch (item.type) {
      case 'edukasi':
        return 'Edukasi Kesehatan';
      case 'makanan':
        return 'Rekomendasi Makanan';
      case 'olahraga':
        return 'Rekomendasi Olahraga';
      default:
        return 'Detail Konten';
    }
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
          item.imageAsset,
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
  // BODY KONTEN
  // ===============================================================

  Widget _buildContentBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KATEGORI BADGE
          if (item.category.isNotEmpty)
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
                item.category.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFA9583C),
                  letterSpacing: 0.8,
                ),
              ),
            ),

          if (item.category.isNotEmpty) const SizedBox(height: 12),

          // JUDUL
          Text(
            item.title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF251814),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 18),

          // DIVIDER
          const Divider(color: Color(0xFFE0CBBE), thickness: 1, height: 1),

          const SizedBox(height: 18),

          // ISI KONTEN
          _buildContentBodyParsed(item.content),
        ],
      ),
    );
  }

  // ===============================================================
  // PARSE KONTEN (HEADING, BULLET, PARAGRAF)
  // ===============================================================

  Widget _buildContentBodyParsed(String content) {
    if (content.isEmpty) {
      return const Text(
        'Konten ini belum memiliki isi.',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          color: Color(0xFF6B5147),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final lines = content.split('\n');
    List<Widget> contentWidgets = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        contentWidgets.add(const SizedBox(height: 10));
        continue;
      }

      // Heading: baris HURUF BESAR SEMUA
      final isAllCaps =
          trimmed.toUpperCase() == trimmed &&
          trimmed.length > 3 &&
          !trimmed.contains(RegExp(r'[.]$')) &&
          !trimmed.startsWith('-') &&
          !trimmed.startsWith('•');

      // List item
      final isList = trimmed.startsWith('-') || trimmed.startsWith('•');
      final isNumbered = RegExp(r'^\d+\.').hasMatch(trimmed);

      if (isAllCaps && !isList && !isNumbered) {
        contentWidgets.add(_buildHeading(trimmed));
      } else if (isList) {
        contentWidgets.add(_buildBullet(trimmed));
      } else if (isNumbered) {
        contentWidgets.add(_buildBullet(trimmed));
      } else {
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
          fontFamily: 'Nunito',
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
            child: Icon(Icons.circle, size: 5, color: Color(0xFFA9583C)),
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
}






