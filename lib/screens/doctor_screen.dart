import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'screening_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import 'doctor_detail_screen.dart';
import 'user_consultations_screen.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  int _selectedIndex = 2;
  int _pageIndex = 0;
  String _searchQuery = '';

  static const Color backgroundColor = Color(0xFFFFF5ED);
  static const Color brown = Color(0xFFB05039);

  Stream<QuerySnapshot<Map<String, dynamic>>> _doctorStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots();
  }

  List<DoctorData> _filterDoctors(List<DoctorData> doctors) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return doctors;
    }

    return doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query);
    }).toList();
  }

  void _onNavigationTap(int index) {
    if (index == 2) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ScreeningScreen(),
        ),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const EdukasiScreen(),
        ),
      );
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 14),
            _buildPageTabs(),
            const SizedBox(height: 14),
            Expanded(
              child: _pageIndex == 0
                  ? _buildDoctorList()
                  : UserConsultationsScreen(
                      searchQuery: _searchQuery,
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 22,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Konsultasi Dokter',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 21,
              color: brown,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Cari dokter atau spesialis',
                  hintStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: Color(0xFF8D8784),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              'Daftar Dokter',
              _pageIndex == 0,
              () {
                setState(() {
                  _pageIndex = 0;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildTab(
              'Konsultasi',
              _pageIndex == 1,
              () {
                setState(() {
                  _pageIndex = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    String title,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: active ? brown : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _doctorStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: brown,
              strokeWidth: 2,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyMessage(
            'Data dokter gagal dimuat',
            'Periksa koneksi internet lalu coba lagi.',
          );
        }

        final doctors = snapshot.data?.docs
                .map(
                  (document) => DoctorData.fromFirestore(
                    document.id,
                    document.data(),
                  ),
                )
                .toList() ??
            [];

        final filteredDoctors = _filterDoctors(doctors);

        if (filteredDoctors.isEmpty) {
          return _buildEmptyMessage(
            'Dokter tidak ditemukan',
            'Coba cari nama dokter atau spesialis.',
          );
        }

        return ListView.separated(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            14,
            0,
            14,
            20,
          ),
          itemCount: filteredDoctors.length,
          separatorBuilder: (_, __) {
            return const SizedBox(height: 12);
          },
          itemBuilder: (context, index) {
            return _buildDoctorCard(
              filteredDoctors[index],
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorCard(DoctorData doctor) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailScreen(
              doctor: doctor,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildDoctorImage(doctor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dr. ${doctor.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 27,
              color: brown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage(DoctorData doctor) {
    const double photoSize = 50;

    if (doctor.photoBase64 != null &&
        doctor.photoBase64!.isNotEmpty) {
      try {
        return Container(
          width: photoSize,
          height: photoSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(
            base64Decode(doctor.photoBase64!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return _fallbackDoctorImage();
            },
          ),
        );
      } catch (_) {}
    }

    if (doctor.photoUrl != null &&
        doctor.photoUrl!.isNotEmpty) {
      return Container(
        width: photoSize,
        height: photoSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          doctor.photoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _fallbackDoctorImage();
          },
        ),
      );
    }

    if (doctor.image.isNotEmpty) {
      return Container(
        width: photoSize,
        height: photoSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          doctor.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _fallbackDoctorImage();
          },
        ),
      );
    }

    return _fallbackDoctorImage();
  }

  Widget _fallbackDoctorImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF4E8DF),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 29,
        color: brown,
      ),
    );
  }

  Widget _buildEmptyMessage(
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services_outlined,
              size: 45,
              color: brown,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorData {
  final String id;
  final String name;
  final String specialty;
  final String status;
  final String rating;
  final String reviews;
  final String image;
  final List<String> schedules;
  final String experience;
  final String education;
  final String location;
  final String? photoBase64;
  final String? photoUrl;

  DoctorData({
    this.id = '',
    required this.name,
    required this.specialty,
    required this.status,
    required this.rating,
    required this.reviews,
    required this.image,
    required this.schedules,
    this.experience = '-',
    this.education = '-',
    this.location = '-',
    this.photoBase64,
    this.photoUrl,
  });

  factory DoctorData.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return DoctorData(
      id: id,
      name: (data['name'] ?? 'Dokter').toString(),
      specialty: (
        data['specialization'] ??
        data['specialty'] ??
        'Dokter Umum'
      ).toString(),
      status: (data['status'] ?? 'Offline').toString(),
      rating: (data['rating'] ?? '0.0').toString(),
      reviews: (data['reviews'] ?? '0').toString(),
      image: (data['image'] ?? '').toString(),
      schedules: data['schedules'] is List
          ? List<String>.from(
              (data['schedules'] as List)
                  .map((item) => item.toString()),
            )
          : [],
      experience:
          (data['experience'] ?? '-').toString(),
      education:
          (data['education'] ?? '-').toString(),
      location:
          (data['location'] ?? '-').toString(),
      photoBase64:
          data['photoBase64']?.toString(),
      photoUrl:
          data['photoUrl']?.toString(),
    );
  }
}