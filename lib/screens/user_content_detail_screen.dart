
import 'package:flutter/material.dart';
import '../services/admin_content_service.dart';

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
  final Set<int> _expandedCards = {};

  bool _isHeading(String line) {
    if (line.isEmpty) return false;
    if (line.startsWith('-') || line.startsWith('•')) return false;
    if (RegExp(r'^\d+\.').hasMatch(line)) return false;
    if (line.length < 3) return false;

    return line.toUpperCase() == line || line.endsWith(':');
  }

  List<_ContentSection> _parseSections(String content) {
    final lines = content.split('\n');
    final sections = <_ContentSection>[];
    _ContentSection? current;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (_isHeading(line)) {
        if (current != null) sections.add(current);
        current = _ContentSection(
          title: line.replaceAll(':', '').trim(),
          items: [],
        );
      } else if (current != null) {
        final numbered = RegExp(r'^\d+\.\s*').firstMatch(line);
        final clean = numbered != null
            ? line.substring(numbered.end)
            : line.replaceFirst(RegExp(r'^[-•]\s*'), '');

        current.items.add(clean);
      }
    }

    if (current != null) sections.add(current);
    return sections;
  }

  String _getIntro(String content) {
    final buffer = <String>[];

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();

      if (_isHeading(line)) break;
      if (line.isNotEmpty) buffer.add(line);
    }

    return buffer.join('\n');
  }

  IconData _getIcon(String title) {
    final t = title.toLowerCase();

    if (t.contains('bahaya') || t.contains('waspada')) {
      return Icons.warning_amber_rounded;
    }
    if (t.contains('gejala')) return Icons.medical_information_outlined;
    if (t.contains('penyebab')) return Icons.search_rounded;
    if (t.contains('dokter')) return Icons.local_hospital_outlined;
    if (t.contains('tips')) return Icons.lightbulb_outline_rounded;
    if (t.contains('penanganan') || t.contains('solusi')) {
      return Icons.healing_rounded;
    }

    return Icons.info_outline_rounded;
  }

  Color _getColor(String title) {
    final t = title.toLowerCase();

    if (t.contains('bahaya') || t.contains('waspada')) {
      return const Color(0xFFEBA21D);
    }
    if (t.contains('dokter')) return const Color(0xFF2E7D4F);
    if (t.contains('tips')) return const Color(0xFF1976D2);

    return const Color(0xFFA9583C);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final intro = _getIntro(item.content);
    final sections = _parseSections(item.content);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
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
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Edukasi GERD',
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
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        item.imageAsset,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          width: double.infinity,
                          color: const Color(0xFFFFE7D8),
                          child: const Icon(
                            Icons.article_outlined,
                            size: 65,
                            color: Color(0xFFB9543A),
                          ),
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
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF251814),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (intro.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE6CB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          intro,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            color: Color(0xFF493C37),
                            height: 1.5,
                          ),
                        ),
                      ),
                    if (intro.isNotEmpty && sections.isNotEmpty)
                      const SizedBox(height: 14),
                    if (item.content.trim().isEmpty)
                      const Text(
                        'Konten ini belum memiliki isi.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: Color(0xFF6B5147),
                        ),
                      )
                    else if (sections.isEmpty)
                      Text(
                        intro,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: Color(0xFF493C37),
                          height: 1.6,
                        ),
                      )
                    else
                      ...List.generate(sections.length, (index) {
                        final section = sections[index];
                        final expanded = _expandedCards.contains(index);
                        final color = _getColor(section.title);

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
                          child: Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(14),
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
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getIcon(section.title),
                                          size: 18,
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
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: expanded ? 0.25 : 0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.chevron_right_rounded,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (expanded)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14, 0, 14, 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(
                                        color: color.withOpacity(0.2),
                                      ),
                                      ...section.items.map(
                                        (text) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                            left: 4,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 7,
                                                ),
                                                child: Icon(
                                                  Icons.circle,
                                                  size: 5,
                                                  color: color,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  text,
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
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentSection {
  final String title;
  final List<String> items;

  _ContentSection({
    required this.title,
    required this.items,
  });
}
