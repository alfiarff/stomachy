
import 'package:flutter/material.dart';

import '../../services/admin_content_service.dart';
import '../user_content_detail_screen.dart';

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
