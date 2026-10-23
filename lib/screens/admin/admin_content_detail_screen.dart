import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';
import '../user_content_detail_screen.dart';

// ===============================================================
// DETAIL KONTEN (ADMIN) - EDUKASI / MAKANAN / OLAHRAGA
// Wrapper: tampilan detail memakai satu sumber yang sama dengan
// sisi user (UserContentDetailScreen), jadi perbaikan tampilan /
// gambar sampul cukup dilakukan di user_content_detail_screen.dart
// dan otomatis berlaku di sisi admin juga.
// ===============================================================

class AdminContentDetailScreen extends StatelessWidget {
  final AdminContentItem item;

  const AdminContentDetailScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return UserContentDetailScreen(item: item);
  }
}