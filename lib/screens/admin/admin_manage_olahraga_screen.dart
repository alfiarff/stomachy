import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';
import '../../widgets/stomachy_cover_image.dart';
import 'admin_content_detail_screen.dart';
import 'admin_olahraga_form_screen.dart';

class AdminManageOlahragaScreen extends StatefulWidget {
  const AdminManageOlahragaScreen({super.key});

  @override
  State<AdminManageOlahragaScreen> createState() =>
      _AdminManageOlahragaScreenState();
}

class _AdminManageOlahragaScreenState extends State<AdminManageOlahragaScreen> {
  static const String contentType = 'olahraga';
  static const Color headingDark = Color(0xFF251814);

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
      floatingActionButton: _buildAddButton(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader('Kelola Olahraga'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 64,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 29,
                    color: Color(0xFF171310),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171310),
                ),
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        cursorColor: const Color(0xFFB05039),
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: headingDark,
        ),
        decoration: InputDecoration(
          hintText: 'Cari olahraga...',
          hintStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminOlahragaFormScreen(),
          ),
        );
      },
      backgroundColor: const Color(0xFFA9583C),
      foregroundColor: Colors.white,
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

  Widget _buildContentList() {
    return StreamBuilder<List<AdminContentItem>>(
      stream: AdminContentService.getContentsStream(contentType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildState('Memuat konten...', Icons.hourglass_empty);
        }

        if (snapshot.hasError) {
          return _buildState(
            'Gagal memuat konten: ${snapshot.error}',
            Icons.error_outline,
          );
        }

        final items = snapshot.data ?? [];
        final keyword = _searchController.text.trim().toLowerCase();

        final filteredItems = items.where((item) {
          return item.title.toLowerCase().contains(keyword) ||
              item.category.toLowerCase().contains(keyword);
        }).toList();

        if (filteredItems.isEmpty) {
          return _buildState(
            keyword.isNotEmpty
                ? 'Olahraga tidak ditemukan'
                : 'Belum ada konten rekomendasi olahraga',
            keyword.isNotEmpty
                ? Icons.search_off_rounded
                : Icons.directions_run_rounded,
          );
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

  Widget _buildContentCard(AdminContentItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminContentDetailScreen(item: item),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
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
                    child: StomachyCoverImage(
                      imageSrc: item.imageAsset,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      fallbackIcon: Icons.directions_run_rounded,
                      fallbackIconSize: 28,
                      fallbackColor: const Color(0xFFB9543A),
                      fallbackBackgroundColor: const Color(0xFFFFE7D8),
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
                  Icons.edit_outlined,
                  'Edit',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminOlahragaFormScreen(
                          editItem: item,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Icons.delete_outline_rounded,
                  'Hapus',
                  () => _showDeleteConfirmation(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
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

  void _showDeleteConfirmation(AdminContentItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Hapus Konten?',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            color: Color(0xFFB9543A),
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus konten ini?',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB05039),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await AdminContentService.deleteContent(item.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Konten berhasil dihapus.'),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildState(String message, IconData icon) {
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
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFFB9543A)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
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