import 'package:flutter/material.dart';

import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===============================================================
  // REGISTER
  // ===============================================================

  void _register() {
    // Untuk sementara setelah daftar langsung masuk ke Beranda.
    //
    // Nanti bagian ini bisa diganti dengan Firebase/
    // database untuk menyimpan akun pengguna.

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EC),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.09,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.035,
                ),

                // =====================================================
                // LOGO
                // =====================================================

                Image.asset(
                  'assets/images/logo_utama_stomachy.png',
                  width: size.width * 0.48,
                  height: size.height * 0.19,
                  fit: BoxFit.contain,
                ),

                // =====================================================
                // PESAN
                // =====================================================

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.025,
                    vertical: size.height * 0.012,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6D5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: size.width * 0.04,
                        color: const Color(0xFFFF7775),
                      ),

                      SizedBox(
                        width: size.width * 0.02,
                      ),

                      Expanded(
                        child: Text(
                          'Yuk, mulai jaga kesehatan lambungmu bersama STOMACHY!',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: size.width * 0.021,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF493C37),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * 0.025,
                ),

                // =====================================================
                // REGISTER CARD
                // =====================================================

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.05,
                    size.height * 0.032,
                    size.width * 0.05,
                    size.height * 0.022,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 5,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // =================================================
                      // JUDUL
                      // =================================================

                      Text(
                        'Selamat Datang!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: size.width * 0.048,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF171310),
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.004,
                      ),

                      Text(
                        'Buat akun baru untuk memulai STOMACHY!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: size.width * 0.023,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.018,
                      ),

                      // =================================================
                      // NAMA LENGKAP
                      // =================================================

                      _buildTextField(
                        controller: nameController,
                        hintText: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        width: size.width,
                      ),

                      SizedBox(
                        height: size.height * 0.012,
                      ),

                      // =================================================
                      // EMAIL / NOMOR HP
                      // =================================================

                      _buildTextField(
                        controller: emailController,
                        hintText: 'Email atau Nomor HP',
                        icon: Icons.email_outlined,
                        width: size.width,
                      ),

                      SizedBox(
                        height: size.height * 0.012,
                      ),

                      // =================================================
                      // PASSWORD
                      // =================================================

                      _buildPasswordField(size),

                      SizedBox(
                        height: size.height * 0.020,
                      ),

                      // =================================================
                      // BUTTON DAFTAR
                      // =================================================

                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.045,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFB7D1B0),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Daftar',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: size.width * 0.030,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: size.height * 0.025,
                      ),

                      // =================================================
                      // ATAU
                      // =================================================

                      _buildDividerText(size),

                      SizedBox(
                        height: size.height * 0.018,
                      ),

                      // =================================================
                      // SOCIAL BUTTON
                      // =================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          _socialButton(
                            icon: Icons.g_mobiledata,
                          ),

                          SizedBox(
                            width: size.width * 0.06,
                          ),

                          _socialButton(
                            icon: Icons.phone_in_talk_outlined,
                          ),
                        ],
                      ),

                      SizedBox(
                        height: size.height * 0.018,
                      ),

                      // =================================================
                      // SUDAH PUNYA AKUN
                      // =================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: size.width * 0.021,
                              color: Colors.grey[700],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Masuk sekarang',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: size.width * 0.021,
                                fontWeight: FontWeight.w700,
                                color:
                                    const Color(0xFFC5674E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * 0.035,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // TEXT FIELD
  // ===============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double width,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: width * 0.022,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: width * 0.022,
          color: Colors.black54,
        ),
        prefixIcon: Icon(
          icon,
          size: width * 0.04,
          color: const Color(0xFF765B4A),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF8D82),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF7775),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PASSWORD FIELD
  // ===============================================================

  Widget _buildPasswordField(Size size) {
    return TextField(
      controller: passwordController,
      obscureText: obscurePassword,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: size.width * 0.022,
      ),
      decoration: InputDecoration(
        hintText: 'Kata Sandi',
        hintStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: size.width * 0.022,
          color: Colors.black54,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          size: size.width * 0.04,
          color: const Color(0xFF765B4A),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: size.width * 0.035,
            color: const Color(0xFF8B817C),
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF8D82),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF7775),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DIVIDER
  // ===============================================================

  Widget _buildDividerText(Size size) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.5,
            color: const Color(0xFFD4D0CC),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Text(
            'atau daftar dengan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: size.width * 0.021,
              color: Colors.grey[600],
            ),
          ),
        ),

        Expanded(
          child: Container(
            height: 0.5,
            color: const Color(0xFFD4D0CC),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SOCIAL BUTTON
  // ===============================================================

  Widget _socialButton({
    required IconData icon,
  }) {
    return SizedBox(
      width: 42,
      height: 42,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF8F4),
          foregroundColor: const Color(0xFFB85E47),
          elevation: 1,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Icon(
          icon,
          size: 25,
        ),
      ),
    );
  }
}