import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  static const Color backgroundColor = Color(0xFFFFF5EF);
  static const Color brown = Color(0xFFB05039);
  static const Color softOrange = Color(0xFFFFE3D1);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _photoBase64;
  bool _obscurePassword = true;
  bool _isSaving = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // PILIH FOTO PROFIL
  // ============================================================

  Future<void> _pickPhoto() async {
    if (_isSaving) return;

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 60,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      if (bytes.length > 700000) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto terlalu besar. Silakan pilih foto lain.'),
          ),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _photoBase64 = base64Encode(bytes);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat foto. Coba lagi.')),
      );
    }
  }

  // ============================================================
  // VALIDASI
  // ============================================================

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }

    if (name.length < 3) {
      return 'Nama minimal 3 karakter.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }

    final regex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

    if (!regex.hasMatch(email)) {
      return 'Format email tidak valid.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }

    if (password.length < 8) {
      return 'Kata sandi minimal 8 karakter.';
    }

    return null;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Gunakan email lain.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      case 'operation-not-allowed':
        return 'Metode email dan kata sandi belum diaktifkan di Firebase.';
      default:
        return 'Gagal membuat akun: ${e.message ?? e.code}';
    }
  }

  // ============================================================
  // SIMPAN AKUN USER
  // ============================================================

  Future<void> _saveAccount() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    final nameError = _validateName(_nameController.text);
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (nameError != null || emailError != null || passwordError != null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;
    User? newUser;
    bool firestoreSaved = false;

    try {
      // Gunakan Firebase App kedua agar sesi admin tidak terganti.
      secondaryApp = await Firebase.initializeApp(
        name: 'createAccount_${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      newUser = credential.user;

      if (newUser == null) {
        throw Exception('Akun gagal dibuat. Silakan coba lagi.');
      }

      try {
        await newUser.updateDisplayName(_nameController.text.trim());
      } catch (_) {
        // Nama tetap tersimpan di dokumen Firestore.
      }

      await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set(
        {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(),
          'role': 'user',
          'photoBase64': _photoBase64 ?? '',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': FirebaseAuth.instance.currentUser?.uid ?? '',
        },
      );

      firestoreSaved = true;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Akun ${_nameController.text.trim()} berhasil dibuat.'),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(_mapAuthError(e)),
        ),
      );
    } catch (e) {
      // Hapus akun Auth baru jika penyimpanan profil gagal.
      if (newUser != null && !firestoreSaved) {
        try {
          await newUser.delete();
        } catch (_) {
          // Jika penghapusan gagal, periksa akun di Firebase Console.
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Gagal menyimpan akun: $e'),
        ),
      );
    } finally {
      try {
        await secondaryAuth?.signOut();
      } catch (_) {}

      try {
        await secondaryApp?.delete();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD HALAMAN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // Tidak menggunakan AppBar agar header menyatu dengan halaman.
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 24),

                // Hanya satu area foto profil.
                _buildPhotoSection(),

                const SizedBox(height: 30),

                _buildLabel('Nama Lengkap (wajib diisi)'),
                const SizedBox(height: 8),
                _buildInputCard(
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isSaving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    style: _inputTextStyle(),
                    decoration: _inputDecoration('Masukkan nama lengkap'),
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() {
                          _nameError = _validateName(_nameController.text);
                        });
                      }
                    },
                  ),
                ),
                _buildFieldError(_nameError),

                const SizedBox(height: 20),

                _buildLabel('Email (wajib diisi)'),
                const SizedBox(height: 8),
                _buildInputCard(
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isSaving,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    style: _inputTextStyle(),
                    decoration: _inputDecoration('Masukkan email pengguna'),
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() {
                          _emailError = _validateEmail(_emailController.text);
                        });
                      }
                    },
                  ),
                ),
                _buildFieldError(_emailError),

                const SizedBox(height: 20),

                _buildLabel('Kata Sandi (wajib diisi)'),
                const SizedBox(height: 8),
                _buildInputCard(
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isSaving,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    style: _inputTextStyle(),
                    decoration:
                        _inputDecoration(
                          'Masukkan kata sandi (min. 8 karakter)',
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: const Color(0xFFAAA19C),
                            ),
                          ),
                        ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() {
                          _passwordError = _validatePassword(
                            _passwordController.text,
                          );
                        });
                      }
                    },
                    onFieldSubmitted: (_) {
                      if (!_isSaving) _saveAccount();
                    },
                  ),
                ),
                _buildFieldError(_passwordError),

                const SizedBox(height: 34),

                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER TRANSPARAN
  // ============================================================

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
              onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                'Tambah Pengguna',
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

  // ============================================================
  // FOTO PROFIL - SATU KOMPONEN
  // ============================================================

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildPhotoPreview(),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: brown,
                        shape: BoxShape.circle,
                        border: Border.all(color: backgroundColor, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Foto Profil (opsional)',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF493C37),
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(_photoBase64!),
          width: 92,
          height: 92,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultPhotoIcon(),
        );
      } catch (_) {
        return _defaultPhotoIcon();
      }
    }

    return _defaultPhotoIcon();
  }

  Widget _defaultPhotoIcon() {
    return const ColoredBox(
      color: Color(0xFFE8E8E8),
      child: Center(child: Icon(Icons.person_rounded, size: 48, color: brown)),
    );
  }

  // ============================================================
  // LABEL DAN KOLOM INPUT
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    );
  }

  TextStyle _inputTextStyle() {
    return const TextStyle(
      fontFamily: 'Nunito',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }

  Widget _buildFieldError(String? error) {
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          error,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            color: Color(0xFFE93636),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: Color(0xFFB8B0AC),
      ),
      filled: true,
      fillColor: Colors.transparent,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  // ============================================================
  // TOMBOL BATAL DAN SIMPAN
  // ============================================================

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: brown,
                disabledBackgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.09),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: brown,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                foregroundColor: Colors.white,
                disabledBackgroundColor: brown,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.12),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: brown,
                      ),
                    )
                  : const Text(
                      'Simpan Data Akun',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
