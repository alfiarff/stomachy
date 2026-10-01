import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/stomachy_card.dart';

class DoctorPersonalInformationScreen
    extends StatefulWidget {
  const DoctorPersonalInformationScreen({
    super.key,
  });

  @override
  State<DoctorPersonalInformationScreen>
      createState() =>
          _DoctorPersonalInformationScreenState();
}

class _DoctorPersonalInformationScreenState
    extends State<DoctorPersonalInformationScreen> {
  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF5EF);

  final Color primaryBrown =
      const Color(0xFF5A392F);

  // ===============================================================
  // CONTROLLER
  // ===============================================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController
      specializationController =
      TextEditingController();

  final TextEditingController
      experienceController =
      TextEditingController();

  final TextEditingController
      educationController =
      TextEditingController();

  final TextEditingController
      locationController =
      TextEditingController();

  // ===============================================================
  // STATUS
  // ===============================================================

  bool _isOnline = false;

  // ===============================================================
  // LOADING
  // ===============================================================

  bool _isLoading = true;
  bool _isSaving = false;

  // ===============================================================
  // FOTO PROFIL
  // ===============================================================

  String? _photoBase64;
  String? _googlePhotoUrl;

  bool _isUploadingPhoto = false;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _loadDoctorData();
  }

  // ===============================================================
  // LOAD DATA DOKTER
  // ===============================================================

  Future<void> _loadDoctorData() async {
    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        return;
      }

      // =============================================================
      // DATA DARI FIREBASE AUTH
      // =============================================================

      nameController.text =
          user.displayName ?? '';

      emailController.text =
          user.email ?? '';

      // =============================================================
      // FOTO GOOGLE
      // =============================================================

      final String authPhoto =
          user.photoURL ?? '';

      if (authPhoto.isNotEmpty &&
          !authPhoto.startsWith('data:')) {
        _googlePhotoUrl = authPhoto;
      }

      // =============================================================
      // DATA FIRESTORE
      // =============================================================

      final DocumentSnapshot<
          Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final Map<String, dynamic>? data =
            doc.data();

        if (data != null) {
          // ---------------------------------------------------------
          // NAMA
          // ---------------------------------------------------------

          final dynamic name =
              data['name'];

          if (name is String &&
              name.trim().isNotEmpty) {
            nameController.text = name;
          }

          // ---------------------------------------------------------
          // EMAIL
          // ---------------------------------------------------------

          final dynamic email =
              data['email'];

          if (email is String &&
              email.trim().isNotEmpty) {
            emailController.text = email;
          }

          // ---------------------------------------------------------
          // SPESIALISASI
          // ---------------------------------------------------------

          final dynamic specialization =
              data['specialization'];

          if (specialization is String) {
            specializationController.text =
                specialization;
          }

          // ---------------------------------------------------------
          // STATUS
          // ---------------------------------------------------------

          final dynamic status =
              data['status'];

          if (status is String) {
            _isOnline =
                status.toLowerCase() == 'online';
          }

          // ---------------------------------------------------------
          // PENGALAMAN
          // ---------------------------------------------------------

          final dynamic experience =
              data['experience'];

          if (experience is String) {
            experienceController.text =
                experience;
          }

          // ---------------------------------------------------------
          // PENDIDIKAN
          // ---------------------------------------------------------

          final dynamic education =
              data['education'];

          if (education is String) {
            educationController.text =
                education;
          }

          // ---------------------------------------------------------
          // LOKASI
          // ---------------------------------------------------------

          final dynamic location =
              data['location'];

          if (location is String) {
            locationController.text =
                location;
          }

          // ---------------------------------------------------------
          // FOTO BASE64
          // ---------------------------------------------------------

          final dynamic photoBase64 =
              data['photoBase64'];

          if (photoBase64 is String &&
              photoBase64.trim().isNotEmpty) {
            _photoBase64 =
                photoBase64;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengambil informasi dokter: $e',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
              ),
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
  // PILIH SUMBER FOTO
  // ===============================================================

  void _showPhotoSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF5A392F),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // =================================================
                // KAMERA
                // =================================================

                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFFFE3D1,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .photo_camera_outlined,
                      size: 22,
                      color:
                          Color(0xFFB65339),
                    ),
                  ),
                  title: const Text(
                    'Ambil dari Kamera',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF30221E),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    _pickAndSavePhoto(
                      ImageSource.camera,
                    );
                  },
                ),

                // =================================================
                // GALERI
                // =================================================

                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFFFE3D1,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .photo_library_outlined,
                      size: 22,
                      color:
                          Color(0xFFB65339),
                    ),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF30221E),
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
  // PILIH DAN SIMPAN FOTO
  // ===============================================================

  Future<void> _pickAndSavePhoto(
    ImageSource source,
  ) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan login terlebih dahulu.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
        ),
      );

      return;
    }

    if (_isUploadingPhoto) {
      return;
    }

    try {
      final XFile? picked =
          await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 55,
      );

      if (picked == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingPhoto = true;
      });

      // ===========================================================
      // KONVERSI FOTO KE BASE64
      // ===========================================================

      final File file =
          File(picked.path);

      final List<int> bytes =
          await file.readAsBytes();

      final String base64String =
          base64Encode(bytes);

      // ===========================================================
      // CEK UKURAN
      // ===========================================================

      if (base64String.length >
          900000) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isUploadingPhoto = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Ukuran foto terlalu besar. Coba pilih foto lain.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
              ),
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

        return;
      }

      // ===========================================================
      // SIMPAN KE FIRESTORE
      // ===========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'photoBase64':
              base64String,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _photoBase64 =
            base64String;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Foto profil berhasil diperbarui.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
          duration:
              Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan foto: $e',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
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
  // SIMPAN DATA DOKTER
  // ===============================================================

  Future<void> _saveDoctorData() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan login terlebih dahulu.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ===========================================================
      // UPDATE NAMA FIREBASE AUTH
      // ===========================================================

      if (nameController.text
              .trim()
              .isNotEmpty &&
          nameController.text.trim() !=
              user.displayName) {
        await user.updateDisplayName(
          nameController.text.trim(),
        );
      }

      // ===========================================================
      // SIMPAN INFORMASI DOKTER
      //
      // STATUS TIDAK DIUBAH DARI HALAMAN INI.
      // STATUS HANYA DIUBAH DARI BERANDA.
      // ===========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name':
              nameController.text.trim(),

          'email':
              emailController.text.trim(),

          'specialization':
              specializationController
                  .text
                  .trim(),

          'experience':
              experienceController
                  .text
                  .trim(),

          'education':
              educationController
                  .text
                  .trim(),

          'location':
              locationController
                  .text
                  .trim(),

          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Informasi pribadi berhasil diperbarui.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
          duration:
              Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan informasi: $e',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
            ),
          ),
          behavior:
              SnackBarBehavior.floating,
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
    specializationController.dispose();
    experienceController.dispose();
    educationController.dispose();
    locationController.dispose();

    super.dispose();
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      Color(0xFFB9543A),
                ),
              )
            : SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  30,
                ),
                child: Column(
                  children: [
                    _buildHeader(),

                    const SizedBox(
                      height: 28,
                    ),

                    _buildProfilePhoto(),

                    const SizedBox(
                      height: 42,
                    ),

                    _buildInformationField(
                      label:
                          'Nama Lengkap',
                      controller:
                          nameController,
                      readOnly: false,
                      hintText:
                          'Masukkan nama lengkap anda',
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    _buildInformationField(
                      label:
                          'Email',
                      controller:
                          emailController,
                      readOnly: true,
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    _buildInformationField(
                      label:
                          'Spesialisasi',
                      controller:
                          specializationController,
                      hintText:
                          'Masukkan spesialisasi anda',
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    _buildStatusField(),

                    const SizedBox(
                      height: 13,
                    ),

                    _buildInformationField(
                      label:
                          'Pengalaman',
                      controller:
                          experienceController,
                      hintText:
                          'Masukkan pengalaman anda',
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    _buildInformationField(
                      label:
                          'Pendidikan',
                      controller:
                          educationController,
                      hintText:
                          'Masukkan pendidikan anda',
                    ),

                    const SizedBox(
                      height: 13,
                    ),

                    _buildInformationField(
                      label:
                          'Lokasi',
                      controller:
                          locationController,
                      hintText:
                          'Masukkan lokasi praktik anda',
                    ),

                    const SizedBox(
                      height: 34,
                    ),

                    _buildEditButton(),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
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
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 45,
              height: 42,
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 29,
                  color:
                      Color(0xFF171310),
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Informasi Pribadi',
                style:
                    const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

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
          decoration:
              const BoxDecoration(
            shape: BoxShape.circle,
            color:
                Color(0xFFE8E8E8),
          ),
          child: ClipOval(
            child:
                _buildPhotoImage(),
          ),
        ),

        if (_isUploadingPhoto)
          Positioned.fill(
            child: Container(
              decoration:
                  const BoxDecoration(
                shape:
                    BoxShape.circle,
                color:
                    Color(0x66000000),
              ),
              child:
                  const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          right: -2,
          bottom: -2,
          child: GestureDetector(
            onTap:
                _isUploadingPhoto
                    ? null
                    : _showPhotoSourcePicker,
            child: Container(
              width: 30,
              height: 30,
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                shape:
                    BoxShape.circle,
                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFE2E2E2,
                  ),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(
                      0.12,
                    ),
                    blurRadius: 3,
                    offset:
                        const Offset(
                      0,
                      1,
                    ),
                  ),
                ],
              ),
              child:
                  const Icon(
                Icons
                    .camera_alt_outlined,
                size: 17,
                color:
                    Color(0xFF3E3936),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // GAMBAR FOTO
  // ===============================================================

  Widget _buildPhotoImage() {
    final String? base64 =
        _photoBase64;

    if (base64 != null &&
        base64.trim().isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(base64),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder:
              (
            context,
            error,
            stackTrace,
          ) {
            return _buildDefaultPhotoIcon();
          },
        );
      } catch (e) {
        return _buildDefaultPhotoIcon();
      }
    }

    final String? googleUrl =
        _googlePhotoUrl;

    if (googleUrl != null &&
        googleUrl.trim().isNotEmpty) {
      return Image.network(
        googleUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return _buildDefaultPhotoIcon();
        },
      );
    }

    return _buildDefaultPhotoIcon();
  }

  // ===============================================================
  // DEFAULT FOTO
  // ===============================================================

  Widget _buildDefaultPhotoIcon() {
    return const SizedBox(
      width: 100,
      height: 100,
      child: Icon(
        Icons.person,
        size: 65,
        color:
            Color(0xFF777777),
      ),
    );
  }

  // ===============================================================
  // STATUS FIELD
  // ===============================================================

  Widget _buildStatusField() {
    return StomachyCard(
      color:
          const Color(0xFFFFFCF9),
      radius: 15,
      padding:
          const EdgeInsets.fromLTRB(
        18,
        8,
        15,
        8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style:
                TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF30221E),
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Row(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration:
                    BoxDecoration(
                  color: _isOnline
                      ? const Color(
                          0xFF54C467,
                        )
                      : const Color(
                          0xFF9E9E9E,
                        ),
                  shape:
                      BoxShape.circle,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                _isOnline
                    ? 'Online'
                    : 'Offline',
                style:
                    const TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w400,
                  color:
                      Color(0xFF493C37),
                ),
              ),
            ],
          ),
        ],
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
    return StomachyCard(
      color:
          const Color(0xFFFFFCF9),
      radius: 15,
      padding:
          const EdgeInsets.fromLTRB(
        18,
        8,
        15,
        7,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF30221E),
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          TextField(
            controller:
                controller,
            readOnly:
                readOnly,
            maxLines:
                maxLines,
            keyboardType:
                keyboardType,
            style:
                const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight:
                  FontWeight.w400,
              color:
                  Color(0xFF493C37),
            ),
            decoration:
                InputDecoration(
              isDense: true,
              hintText:
                  hintText,
              hintStyle:
                  const TextStyle(
                fontFamily:
                    'Nunito',
                fontSize: 11,
                fontWeight:
                    FontWeight.w400,
                color:
                    Color(0xFF999999),
              ),
              border:
                  InputBorder.none,
              contentPadding:
                  EdgeInsets.zero,
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
        onPressed:
            _isSaving
                ? null
                : _saveDoctorData,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(
            0xFFB9543A,
          ),
          foregroundColor:
              Colors.white,
          disabledBackgroundColor:
              const Color(
            0xFFB9543A,
          ),
          disabledForegroundColor:
              Colors.white,
          elevation: 3,
          shadowColor:
              Colors.black.withOpacity(
            0.20,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              25,
            ),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      Colors.white,
                ),
              )
            : const Text(
                'Ubah Informasi',
                style:
                    TextStyle(
                  fontFamily:
                      'Nunito',
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
      ),
    );
  }
}