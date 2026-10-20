import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';

// ===============================================================
// DETAIL ARTIKEL (ADMIN)
// ===============================================================

class AdminArticleDetailScreen extends StatelessWidget {
  final AdminArticle article;

  const AdminArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFFFF5EF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(context),

            // KONTEN
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CHIP STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: article.isPublished
                                  ? const Color(0xFF2E9E5B)
                                  : const Color(0xFFEBA21D),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            article.isPublished
                                ? 'Tayang Sekarang'
                                : 'Draf',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: article.isPublished
                                  ? const Color(0xFF2E7D4F)
                                  : const Color(0xFF9C6F1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // JUDUL ARTIKEL
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF251814),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // RINGKASAN (italic)
                    Text(
                      article.summary,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF6B5147),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // GARIS PEMISAH
                    const Divider(
                      color: Color(0xFFE0CBBE),
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),

                    // GAMBAR ARTIKEL
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE7D8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            article.imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.article_outlined,
                                size: 60,
                                color: Color(0xFFB9543A),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ISI ARTIKEL
                    const Text(
                      'Isi Artikel',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF251814),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.content.isEmpty
                          ? article.summary
                          : article.content,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: Color(0xFF493C37),
                        height: 1.6,
                      ),
                    ),
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
          const Expanded(
            child: Center(
              child: Text(
                'Detail Artikel',
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
    );
  }
}