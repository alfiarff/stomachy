import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ===============================================================
  // LOAD USER DATA
  // ===============================================================

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Data dasar dari Firebase Authentication
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';

      // Data tambahan dari Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          final name = data['name'];
          final email = data['email'];
          final phone = data['phone'];
          final birth = data['birth'];
          final gender = data['gender'];
          final address = data['address'];

          if (name is String && name.trim().isNotEmpty) {
            nameController.text = name;
          }

          if (email is String && email.trim().isNotEmpty) {
            emailController.text = email;
          }

          if (phone is String) {
            phoneController.text = phone;
          }

          if (birth is String) {
            birthController.text = birth;
          }

          if (gender is String) {
            genderController.text = gender;
          }

          if (address is String) {
            addressController.text = address;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengambil informasi pengguna: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===============================================================
  // SAVE USER DATA
  // ===============================================================

  Future<void> _saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update nama di Firebase Authentication
      if (nameController.text.trim().isNotEmpty &&
          nameController.text.trim() != user.displayName) {
        await user.updateDisplayName(
          nameController.text.trim(),
        );
      }

      // Simpan seluruh informasi ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'birth': birthController.text.trim(),
          'gender': genderController.text.trim(),
          'address': addressController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informasi pribadi berhasil diperbarui.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan informasi: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFB9543A),
                ),
              )
            : SingleChildScrollView(
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
                      readOnly: false,
                      hintText: 'Masukkan nama lengkap anda',
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
                      keyboardType: TextInputType.phone,
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
    TextInputType? keyboardType,
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
            keyboardType: keyboardType,
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
        onPressed: _isSaving ? null : _saveUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB9543A),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB9543A),
          disabledForegroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Ubah Informasi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
