import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Dokter'),
      ),
      body: const Center(
        child: Text('Halaman Profil Dokter'),
      ),
    );
  }
}