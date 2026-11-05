
import 'package:flutter/material.dart';
import 'admin_add_account_screen.dart';

class AdminAddAdminScreen extends StatelessWidget {
  const AdminAddAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminAddAccountScreen(
      accountRole: 'admin',
      pageTitle: 'Tambah Admin',
    );
  }
}
