
import 'package:flutter/material.dart';
import 'admin_add_account_screen.dart';

class AdminAddUserScreen extends StatelessWidget {
  const AdminAddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminAddAccountScreen(
      accountRole: 'user',
      pageTitle: 'Tambah Pengguna',
    );
  }
}
