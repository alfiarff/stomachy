import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'edukasi_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  int _selectedIndex = 4;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF5A392F);

  // ===============================================================
  // CONTROLLER
  // ===============================================================

  final TextEditingController nameController =
      TextEditingController(text: 'Jerome Polin');

  final TextEditingController emailController =
      TextEditingController(text: 'jeromepolin12@gmail.com');

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController birthController =
      TextEditingController();

  final TextEditingController genderController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthController.dispose();
    genderController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ===============================================================
  // NAVIGATION
  // ===============================================================

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) {
      return;
    }

    // BERANDA
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // SKRINING
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScreeningScreen(),
        ),
      );
      return;
    }

    // DOKTER
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DoctorScreen(),
        ),
      );
      return;
    }

    // EDUKASI
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EdukasiScreen(),
        ),
      );
      return;
    }

    // PROFIL
    if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            105,
          ),
          child: Column(
            children: [

              // ===================================================
              // HEADER
              // ===================================================

              _buildHeader(),

              const SizedBox(height: 28),

              // ===================================================
              // FOTO PROFIL
              // ===================================================

              _buildProfilePhoto(),

              const SizedBox(height: 42),

              // ===================================================
              // INFORMASI PRIBADI
              // ===================================================

              _buildInformationField(
                label: 'Nama Lengkap',
                controller: nameController,
                readOnly: true,
              ),

              const SizedBox(height: 13),

              _buildInformationField(
                label: 'Email',
                controller: emailController,
                readOnly: true,
              ),

              const SizedBox(height: 13),

              _buildInformationField(
                label: 'Nomor Telepon',
                controller: phoneController,
                hintText: 'Masukkan nomor telepon anda',
              ),

              const SizedBox(height: 13),

              _buildInformationField(
                label: 'Tempat, Tanggal Lahir',
                controller: birthController,
                hintText: 'Masukkan tempat, tanggal lahir anda',
              ),

              const SizedBox(height: 13),

              _buildInformationField(
                label: 'Jenis Kelamin',
                controller: genderController,
                hintText: 'Masukkan jenis kelamin anda',
              ),

              const SizedBox(height: 13),

              _buildInformationField(
                label: 'Alamat',
                controller: addressController,
                hintText: 'Masukkan alamat anda',
                maxLines: 2,
              ),

              const SizedBox(height: 34),

              // ===================================================
              // TOMBOL UBAH INFORMASI
              // ===================================================

              _buildEditButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // =========================================================
      // BOTTOM NAVIGATION
      // =========================================================

      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [

          // TOMBOL KEMBALI
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 45,
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

          // JUDUL
          Expanded(
            child: Center(
              child: Text(
                'Informasi Pribadi',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // PENYEIMBANG HEADER
          const SizedBox(
            width: 45,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FOTO PROFIL
  // ===============================================================

  Widget _buildProfilePhoto() {
    return Stack(
      clipBehavior: Clip.none,
      children: [

        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8E8E8),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profil_jerome.jpeg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 65,
                  color: Color(0xFF777777),
                );
              },
            ),
          ),
        ),

        // ICON KAMERA
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2E2E2),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: Color(0xFF3E3936),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // INFORMATION FIELD
  // ===============================================================

  Widget _buildInformationField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 48,
      ),
      padding: const EdgeInsets.fromLTRB(
        25,
        8,
        15,
        7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFF806A),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // LABEL
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF30221E),
            ),
          ),

          const SizedBox(height: 2),

          // INPUT
          TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF493C37),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BUTTON UBAH INFORMASI
  // ===============================================================

  Widget _buildEditButton() {
    return SizedBox(
      width: 228,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          _showEditMessage();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB9543A),
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Ubah Informasi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // MESSAGE
  // ===============================================================

  void _showEditMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Informasi pribadi berhasil diperbarui.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}