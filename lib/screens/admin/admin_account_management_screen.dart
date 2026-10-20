import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_add_account_screen.dart';

// ===============================================================
// MANAJEMEN AKUN (ADMIN)
//
// - Sumber data : koleksi 'users' (realtime via snapshots)
// - Tab Dokter  : akun dengan role 'dokter' / 'doctor'
// - Tab Pengguna: akun role 'user' (atau tanpa role)
// - Akun admin TIDAK ditampilkan di daftar.
// - Switch      : mengubah field 'isActive' (true/false) di
//                 dokumen user. Default (field belum ada) = aktif.
// ===============================================================

class AdminAccountManagementScreen extends StatefulWidget {
  const AdminAccountManagementScreen({super.key});

  @override
  State<AdminAccountManagementScreen> createState() =>
      _AdminAccountManagementScreenState();
}

class _AdminAccountManagementScreenState
    extends State<AdminAccountManagementScreen> {
  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color brown = const Color(0xFFB05039);
  final Color softOrange = const Color(0xFFFFE3D1);
  final Color redAccent = const Color(0xFFE93636);

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // Tab aktif: 'dokter' | 'pengguna'
  String _selectedTab = 'dokter';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ===============================================================
  // HELPERS DATA
  // ===============================================================

  bool _isDoctorRole(String role) {
    final String r = role.trim().toLowerCase();
    return r == 'dokter' || r == 'doctor';
  }

  String _accountName(Map<String, dynamic> data) {
    return (data['name'] ?? '').toString().trim();
  }

  String _accountEmail(Map<String, dynamic> data) {
    return (data['email'] ?? '').toString().trim();
  }

  // Nama dokter ditampilkan dengan awalan "dr." seperti desain.
  String _displayDoctorName(String name) {
    if (name.isEmpty) return 'Dokter';
    if (name.toLowerCase().startsWith('dr.')) return name;
    return 'dr. $name';
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterAccounts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filtered = docs.where((doc) {
      final data = doc.data();
      final String role = (data['role'] ?? '').toString();

      // Akun admin tidak ditampilkan di daftar ini.
      if (role.trim().toLowerCase() == 'admin') {
        return false;
      }

      if (_selectedTab == 'dokter') {
        if (!_isDoctorRole(role)) return false;
      } else {
        if (_isDoctorRole(role)) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final String name = _accountName(data).toLowerCase();
        final String email = _accountEmail(data).toLowerCase();

        if (!name.contains(_searchQuery) && !email.contains(_searchQuery)) {
          return false;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      final String nameA = _accountName(a.data()).toLowerCase();
      final String nameB = _accountName(b.data()).toLowerCase();
      return nameA.compareTo(nameB);
    });

    return filtered;
  }

  // ===============================================================
  // AKTIF / NONAKTIFKAN AKUN
  // ===============================================================

  Future<void> _toggleAccountStatus({
    required String uid,
    required String name,
    required bool value,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'isActive': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            value ? 'Akun $name diaktifkan.' : 'Akun $name dinonaktifkan.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Gagal mengubah status akun: $e'),
        ),
      );
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: _buildAddButton(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _buildSearchField(),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _buildTabBar(),
            ),

            const SizedBox(height: 16),

            Expanded(child: _buildAccountList()),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 45,
            height: 44,
            child: IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 29,
                color: Color(0xFF171310),
              ),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Manajemen Akun',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(width: 45),
        ],
      ),
    );
  }

  // ===============================================================
  // SEARCH BAR
  // ===============================================================

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
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
        cursorColor: brown,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Cari nama akun...',
          hintStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB8B0AC),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFFB8B0AC),
          ),
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ===============================================================
  // TAB DOKTER / PENGGUNA
  // ===============================================================

  Widget _buildTabBar() {
    return Row(
      children: [
        Expanded(
          child: _buildTabButton(label: 'Dokter', value: 'dokter'),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildTabButton(label: 'Pengguna', value: 'pengguna'),
        ),
      ],
    );
  }

  Widget _buildTabButton({required String label, required String value}) {
    final bool selected = _selectedTab == value;

    return GestureDetector(
      onTap: () {
        if (_selectedTab == value) return;
        setState(() {
          _selectedTab = value;
        });
      },
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? brown : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(selected ? 0.15 : 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF493C37),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DAFTAR AKUN
  // ===============================================================

  Widget _buildAccountList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB9543A)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat daftar akun.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          );
        }

        final docs =
            snapshot.data?.docs ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];

        final filtered = _filterAccounts(docs);

        if (filtered.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
          child: Column(
            children: [
              for (int i = 0; i < filtered.length; i++) ...[
                _buildAccountCard(filtered[i]),

                if (i != filtered.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  // ===============================================================
  // KARTU AKUN
  // ===============================================================

  Widget _buildAccountCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final String uid = doc.id;
    final String role = (data['role'] ?? '').toString();
    final bool isDoctor = _isDoctorRole(role);

    String name = _accountName(data);
    if (isDoctor) {
      name = _displayDoctorName(name);
    }
    if (name.isEmpty) name = 'Tanpa Nama';

    final String email = _accountEmail(data);

    // Default aktif jika field 'isActive' belum ada.
    final bool isActive = data['isActive'] != false;

    String photoValue = (data['photoBase64'] ?? '').toString().trim();

    if (photoValue.startsWith('data:') && photoValue.contains(',')) {
      photoValue = photoValue.substring(photoValue.indexOf(',') + 1);
    }

    final String? photoBase64 = photoValue.isNotEmpty ? photoValue : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE5D8),
              shape: BoxShape.circle,
            ),
            child: ClipOval(child: _buildAvatar(photoBase64)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  email.isEmpty ? '-' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF776C67),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Switch(
            value: isActive,
            onChanged: (value) {
              _toggleAccountStatus(uid: uid, name: name, value: value);
            },
            thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return const Color(0xFFB8B0AC);
            }),
            trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFFB9543A);
              }
              return const Color(0xFFE5DDD8);
            }),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? photoBase64) {
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(photoBase64),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _defaultAvatarIcon();
          },
        );
      } catch (e) {
        return _defaultAvatarIcon();
      }
    }

    return _defaultAvatarIcon();
  }

  Widget _defaultAvatarIcon() {
    return Container(
      color: const Color(0xFFFFE5D8),
      child: const Icon(
        Icons.person_rounded,
        size: 30,
        color: Color(0xFFB05039),
      ),
    );
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _buildEmptyState() {
    final bool isSearching = _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 50,
                color: Color(0xFFB05039),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              isSearching ? 'Akun Tidak Ditemukan' : 'Belum Ada Akun',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171310),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isSearching
                  ? 'Coba kata kunci lain untuk mencari akun.'
                  : _selectedTab == 'dokter'
                  ? 'Belum ada akun dokter. Tambahkan lewat tombol + di bawah.'
                  : 'Belum ada pengguna terdaftar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF493C37),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // TOMBOL + (TAMBAH DOKTER)
  // ===============================================================

  Widget _buildAddButton() {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        heroTag: 'addAccountFab',
        backgroundColor: brown,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminAddAccountScreen(),
            ),
          );
        },
        child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
      ),
    );
  }
}
