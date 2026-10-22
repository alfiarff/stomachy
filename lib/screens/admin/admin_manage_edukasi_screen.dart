import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';

// ===============================================================
// DETAIL KONTEN (ADMIN) - ACCORDION / EXPANDABLE CARDS
// ===============================================================

class AdminContentDetailScreen extends StatefulWidget {
  final AdminContentItem item;

  const AdminContentDetailScreen({super.key, required this.item});

  @override
  State<AdminContentDetailScreen> createState() =>
      _AdminContentDetailScreenState();
}

class _AdminContentDetailScreenState extends State<AdminContentDetailScreen> {
  // Track which cards are expanded
  final Set<int> _expandedCards = {};

  void _toggleCard(int index) {
    setState(() {
      if (_expandedCards.contains(index)) {
        _expandedCards.remove(index);
      } else {
        _expandedCards.add(index);
      }
    });
  }

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
                    _buildContentBody(),
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
            const Expanded(
              child: Center(
                child: Text(
                  'Edukasi Kesehatan',
                  style: TextStyle(
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
          widget.item.imageAsset,
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
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KATEGORI BADGE
          if (widget.item.category.isNotEmpty)
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
                widget.item.category.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFA9583C),
                  letterSpacing: 0.8,
                ),
              ),
            ),

          if (widget.item.category.isNotEmpty) const SizedBox(height: 10),

          // JUDUL
          Text(
            widget.item.title,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF251814),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // PARSE CONTENT JADI ACCORDION CARDS
          _buildAccordionCards(widget.item.content),
        ],
      ),
    );
  }

  // ===============================================================
  // PARSE KONTEN JADI ACCORDION CARDS
  // ===============================================================

  Widget _buildAccordionCards(String content) {
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

    // Cari paragraf pembuka (sebelum heading pertama)
    final introBuffer = StringBuffer();
    int i = 0;
    for (; i < lines.length; i++) {
      final line = lines[i].trim();
      if (_isHeading(line)) break;
      if (line.isNotEmpty) {
        if (introBuffer.isNotEmpty) introBuffer.write('\n');
        introBuffer.write(line);
      }
    }

    // Kelompokkan sisa baris jadi sections
    final sections = <_ContentSection>[];
    _ContentSection? current;

    for (; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (_isHeading(line)) {
        if (current != null) sections.add(current);
        current = _ContentSection(title: line, items: []);
      } else if (current != null) {
        final cleanText = line.replaceFirst(RegExp(r'^[-•]\s*'), '');
        final numberedMatch = RegExp(r'^\d+\.\s*').firstMatch(line);
        final cleanNumbered = numberedMatch != null
            ? line.substring(numberedMatch.end)
            : cleanText;
        current.items.add(cleanNumbered);
      }
    }
    if (current != null) sections.add(current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intro paragraf (kotak definisi)
        if (introBuffer.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6CB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFA9583C).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              introBuffer.toString(),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Color(0xFF493C37),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        // Accordion Cards
        for (int idx = 0; idx < sections.length; idx++)
          _buildAccordionCard(idx, sections[idx]),
      ],
    );
  }

  bool _isHeading(String line) {
    if (line.isEmpty) return false;
    if (line.startsWith('-') || line.startsWith('•')) return false;
    if (RegExp(r'^\d+\.').hasMatch(line)) return false;
    if (line.length < 3) return false;
    return line.toUpperCase() == line || line.endsWith(':');
  }

  // ===============================================================
  // ACCORDION CARD (Bisa dipencet untuk expand/collapse)
  // ===============================================================

  Widget _buildAccordionCard(int index, _ContentSection section) {
    final isExpanded = _expandedCards.contains(index);
    final icon = _getIconForSection(section.title);
    final color = _getColorForSection(section.title);
    final cleanTitle = section.title.replaceAll(':', '').trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _toggleCard(index),
          child: Column(
            children: [
              // HEADER CARD (selalu tampil)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cleanTitle,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Arrow icon (rotate when expanded)
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              // CONTENT (hanya saat expanded)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: color.withOpacity(0.2),
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 10),
                      ...section.items.map((itemText) => Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Icon(Icons.circle,
                                      size: 5, color: color),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    itemText,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 12,
                                      color: Color(0xFF493C37),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForSection(String title) {
    final t = title.toLowerCase();
    if (t.contains('jangan') || t.contains('abaikan'))
      return Icons.priority_high_rounded;
    if (t.contains('diwaspadai') || t.contains('bahaya'))
      return Icons.warning_amber_rounded;
    if (t.contains('gejala') && t.contains('umum'))
      return Icons.list_alt_rounded;
    if (t.contains('penyebab')) return Icons.search_rounded;
    if (t.contains('gejala')) return Icons.warning_amber_rounded;
    if (t.contains('dampak')) return Icons.error_outline_rounded;
    if (t.contains('dokter')) return Icons.local_hospital_rounded;
    if (t.contains('data') || t.contains('prevalensi'))
      return Icons.bar_chart_rounded;
    if (t.contains('tips')) return Icons.lightbulb_outline_rounded;
    if (t.contains('penanganan') || t.contains('solusi'))
      return Icons.healing_rounded;
    return Icons.info_outline_rounded;
  }

  Color _getColorForSection(String title) {
    final t = title.toLowerCase();
    if (t.contains('jangan') || t.contains('abaikan'))
      return const Color(0xFFD32F2F);
    if (t.contains('diwaspadai') || t.contains('bahaya'))
      return const Color(0xFFEBA21D);
    if (t.contains('gejala') && t.contains('umum'))
      return const Color(0xFFA9583C);
    if (t.contains('penyebab')) return const Color(0xFFA9583C);
    if (t.contains('gejala')) return const Color(0xFFEBA21D);
    if (t.contains('dampak')) return const Color(0xFFD32F2F);
    if (t.contains('dokter')) return const Color(0xFF2E7D4F);
    if (t.contains('data') || t.contains('prevalensi'))
      return const Color(0xFF607D8B);
    if (t.contains('tips')) return const Color(0xFF1976D2);
    if (t.contains('penanganan') || t.contains('solusi'))
      return const Color(0xFF7B1FA2);
    return const Color(0xFFA9583C);
  }
}

class _ContentSection {
  final String title;
  final List<String> items;

  _ContentSection({required this.title, required this.items});
}