
import 'package:flutter/material.dart';
import '../services/admin_content_service.dart';
import '../../widgets/stomachy_cover_image.dart';

class UserContentDetailScreen extends StatefulWidget {
  final AdminContentItem item;

  const UserContentDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<UserContentDetailScreen> createState() =>
      _UserContentDetailScreenState();
}

class _UserContentDetailScreenState
    extends State<UserContentDetailScreen> {
  final Set<int> _expandedCards = {0};

  static const Color _background = Color(0xFFFFF5EF);
  static const Color _brown = Color(0xFF493028);
  static const Color _accent = Color(0xFFA9583C);

  List<_ContentSection> _getSections(AdminContentItem item) {
    // Prioritaskan struktur sections dari Firestore.
    if (item.sections.isNotEmpty) {
      return item.sections.map((section) {
        final rawPoints = section['points'];
        final points = rawPoints is List
            ? rawPoints
                .map((point) => point.toString().trim())
                .where((point) => point.isNotEmpty)
                .toList()
            : <String>[];

        return _ContentSection(
          title: section['title']?.toString().trim().isNotEmpty == true
              ? section['title'].toString().trim()
              : 'Materi',
          points: points,
        );
      }).toList();
    }

    // Fallback untuk edukasi lama yang hanya menyimpan content.
    return _parseLegacyContent(item.content);
  }

  List<_ContentSection> _parseLegacyContent(String content) {
    final sections = <_ContentSection>[];
    final lines = content.split('\n');
    String? title;
    List<String> points = [];
    final introLines = <String>[];

    bool isHeading(String line) {
      final text = line.trim();
      if (text.isEmpty) return false;
      if (text.startsWith('-') || text.startsWith('•')) return false;
      if (RegExp(r'^\d+\.\s*').hasMatch(text)) return false;

      return text.endsWith(':') ||
          (text.length > 3 && text.toUpperCase() == text);
    }

    void saveSection() {
      if (title != null) {
        sections.add(_ContentSection(
          title: title!,
          points: List<String>.from(points),
        ));
      }
    }

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (isHeading(line)) {
        saveSection();
        title = line.replaceAll(RegExp(r':$'), '').trim();
        points = [];
      } else if (title != null) {
        final numbered = RegExp(r'^\d+\.\s*').firstMatch(line);
        final clean = numbered != null
            ? line.substring(numbered.end)
            : line.replaceFirst(RegExp(r'^[-•]\s*'), '');

        points.add(clean);
      } else {
        introLines.add(line);
      }
    }

    saveSection();

    // Konten tanpa heading tetap ditampilkan sebagai satu card.
    if (sections.isEmpty && introLines.isNotEmpty) {
      sections.add(_ContentSection(
        title: 'Materi',
        points: introLines,
      ));
    }

    return sections;
  }

  IconData _getIcon(String title) {
    final text = title.toLowerCase();

    if (text.contains('bahaya') || text.contains('waspada')) {
      return Icons.warning_amber_rounded;
    }
    if (text.contains('gejala')) {
      return Icons.medical_information_outlined;
    }
    if (text.contains('penyebab')) {
      return Icons.search_rounded;
    }
    if (text.contains('dokter')) {
      return Icons.local_hospital_outlined;
    }
    if (text.contains('tips')) {
      return Icons.lightbulb_outline_rounded;
    }
    if (text.contains('penanganan') || text.contains('solusi')) {
      return Icons.healing_rounded;
    }

    return Icons.info_outline_rounded;
  }

  Color _getColor(String title) {
    final text = title.toLowerCase();

    if (text.contains('bahaya') || text.contains('waspada')) {
      return const Color(0xFFEBA21D);
    }
    if (text.contains('dokter')) {
      return const Color(0xFF2E7D4F);
    }
    if (text.contains('tips')) {
      return const Color(0xFF1976D2);
    }
    if (text.contains('gejala')) {
      return const Color(0xFF7B6BD0);
    }

    return _accent;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final sections = _getSections(item);
    final summary = item.summary.trim();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 42,
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
                          item.type == 'edukasi'
                              ? 'Edukasi Kesehatan'
                              : item.type == 'makanan'
                                  ? 'Rekomendasi Makanan'
                                  : item.type == 'olahraga'
                                      ? 'Rekomendasi Olahraga'
                                      : 'Detail Konten',
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
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE7D8),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: StomachyCoverImage(
                          imageSrc: item.imageAsset,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.menu_book_rounded,
                          fallbackIconSize: 65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (item.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE7D8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _accent.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _accent,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

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

                    const SizedBox(height: 16),

                    if (summary.isNotEmpty) ...[
                      Text(
                        summary,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF493C37),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ] else if (item.content.trim().isNotEmpty) ...[
                      Text(
                        _getLegacyIntro(item.content),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF493C37),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    if (sections.isEmpty)
                      const Text(
                        'Konten ini belum memiliki isi.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: Color(0xFF6B5147),
                        ),
                      )
                    else
                      for (int i = 0; i < sections.length; i++) ...[
                        _buildInfoCard(sections[i], i),
                        if (i != sections.length - 1)
                          const SizedBox(height: 12),
                      ],

                    const SizedBox(height: 16),

                    if (item.type == 'edukasi') _buildRememberBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLegacyIntro(String content) {
    final lines = content.split('\n');
    final result = <String>[];

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      final isHeading = line.endsWith(':') ||
          (line.length > 3 && line.toUpperCase() == line);

      if (isHeading) break;
      result.add(line);
    }

    return result.join('\n');
  }

  Widget _buildInfoCard(_ContentSection section, int index) {
    final expanded = _expandedCards.contains(index);
    final color = _getColor(section.title);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                if (expanded) {
                  _expandedCards.remove(index);
                } else {
                  _expandedCards.add(index);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIcon(section.title),
                      size: 19,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171310),
                      ),
                    ),
                  ),
                  Text(
                    '${section.points.length} poin',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      color: Color(0xFF9A8F89),
                    ),
                  ),
                  const SizedBox(width: 5),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: Color(0xFF9A8F89),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeOut,
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(
              width: double.infinity,
            ),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: color.withOpacity(0.2)),
                  for (final point in section.points)
                    _buildBulletItem(point, color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 5, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF493C37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4D2),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingat!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171310),
            ),
          ),
          SizedBox(height: 3),
          Text(
            'Pahami informasi kesehatan dengan baik. Jika gejala '
            'mengganggu atau berulang, konsultasikan kepada tenaga '
            'kesehatan.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              height: 1.5,
              color: Color(0xFF30221E),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSection {
  final String title;
  final List<String> points;

  const _ContentSection({
    required this.title,
    required this.points,
  });
}
