import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
  // FOTO PROFIL
  //
  // Disimpan sebagai Base64 di Firestore (field: photoBase64)
  // -> GRATIS, tidak butuh Firebase Storage (berbayar).
  // ===============================================================

  String? _photoBase64;
  String? _googlePhotoUrl; // foto Google (kalau akunnya Google)

  bool _isUploadingPhoto = false;

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

      // Foto Google (fallback kalau belum upload foto sendiri)
      final String authPhoto = user.photoURL ?? '';

      if (authPhoto.isNotEmpty &&
          !authPhoto.startsWith('data:')) {
        _googlePhotoUrl = authPhoto;
      }

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
          final photoBase64 = data['photoBase64'];

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

          // Foto Base64 dari Firestore (prioritas utama)
          if (photoBase64 is String &&
              photoBase64.trim().isNotEmpty) {
            _photoBase64 = photoBase64;
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
  // PILIH SUMBER FOTO (KAMERA / GALERI)
  // ===============================================================

  void _showPhotoSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5A392F),
                  ),
                ),

                const SizedBox(height: 14),

                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE3D1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: 22,
                      color: Color(0xFFB65339),
                    ),
                  ),
                  title: const Text(
                    'Ambil dari Kamera',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF30221E),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSavePhoto(
                      ImageSource.camera,
                    );
                  },
                ),

                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE3D1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      size: 22,
                      color: Color(0xFFB65339),
                    ),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF30221E),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSavePhoto(
                      ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // PILIH + SIMPAN FOTO SEBAGAI BASE64 DI FIRESTORE
  //
  // Foto dikompres kecil (512px, kualitas 55) supaya hasil
  // Base64-nya jauh di bawah batas 1 MB dokumen Firestore.
  // ===============================================================

  Future<void> _pickAndSavePhoto(
    ImageSource source,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu.'),
        ),
      );
      return;
    }

    if (_isUploadingPhoto) return;

    try {
      // ---------------------------------------------------------
      // PILIH FOTO (dikompres biar ringan)
      // ---------------------------------------------------------
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 55,
      );

      // User batal memilih
      if (picked == null) return;

      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      // ---------------------------------------------------------
      // KONVERSI KE BASE64
      // ---------------------------------------------------------
      final File file = File(picked.path);

      final List<int> bytes = await file.readAsBytes();

      final String base64String = base64Encode(bytes);

      // ---------------------------------------------------------
      // PENJAGAAN: dokumen Firestore max 1 MB
      // 900.000 karakter Base64 ~ 675 KB foto asli (sangat aman)
      // ---------------------------------------------------------
      if (base64String.length > 900000) {
        if (!mounted) return;

        setState(() {
          _isUploadingPhoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ukuran foto terlalu besar. Coba pilih foto lain.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // ---------------------------------------------------------
      // SIMPAN KE FIRESTORE
      // ---------------------------------------------------------
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'photoBase64': base64String,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        _photoBase64 = base64String;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto profil berhasil diperbarui.',
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
            'Gagal menyimpan foto: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
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
  //
  // Prioritas tampil:
  // 1. Foto Base64 (hasil upload pengguna sendiri)
  // 2. Foto Google (kalau akunnya Google dan belum upload)
  // 3. Ikon person default (pengguna baru)
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
            child: _buildPhotoImage(),
          ),
        ),

        // LOADING SAAT PROSES SIMPAN FOTO
        if (_isUploadingPhoto)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x66000000),
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        // ICON KAMERA (TAP UNTUK UBAH FOTO)
        Positioned(
          right: -2,
          bottom: -2,
          child: GestureDetector(
            onTap:
                _isUploadingPhoto ? null : _showPhotoSourcePicker,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE2E2E2),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 17,
                color: Color(0xFF3E3936),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // GAMBAR FOTO (BASE64 / GOOGLE URL / DEFAULT)
  // ===============================================================

  Widget _buildPhotoImage() {
    // 1. Foto Base64 (upload pengguna)
    final String? base64 = _photoBase64;

    if (base64 != null && base64.trim().isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(base64),
          width: 100,
          height: 100,
          fit: BoxFit.cover,

          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultPhotoIcon();
          },
        );
      } catch (e) {
        return _buildDefaultPhotoIcon();
      }
    }

    // 2. Foto Google
    final String? googleUrl = _googlePhotoUrl;

    if (googleUrl != null && googleUrl.trim().isNotEmpty) {
      return Image.network(
        googleUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultPhotoIcon();
        },
      );
    }

    // 3. Default
    return _buildDefaultPhotoIcon();
  }

  Widget _buildDefaultPhotoIcon() {
    return const SizedBox(
      width: 100,
      height: 100,
      child: Icon(
        Icons.person,
        size: 65,
        color: Color(0xFF777777),
      ),
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