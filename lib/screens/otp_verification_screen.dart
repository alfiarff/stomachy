import 'dart:async';

import 'package:flutter/material.dart';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String emailOrPhone;

  const OtpVerificationScreen({
    super.key,
    required this.emailOrPhone,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {

  // ===============================================================
  // CONTROLLER OTP
  // ===============================================================

  final List<TextEditingController> otpControllers =
      List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes =
      List.generate(
    6,
    (index) => FocusNode(),
  );

  // ===============================================================
  // TIMER
  // ===============================================================

  Timer? _timer;

  int _remainingSeconds = 30;

  // ===============================================================
  // WARNA
  // ===============================================================

  final Color backgroundColor =
      const Color(0xFFFFF4EC);

  final Color brown =
      const Color(0xFFB05039);

  final Color borderColor =
      const Color(0xFFFF7775);

  final Color darkText =
      const Color(0xFF493C37);

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  // ===============================================================
  // TIMER MULAI
  // ===============================================================

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 30;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  // ===============================================================
  // FORMAT TIMER
  // ===============================================================

  String get _timerText {
    final minutes =
        (_remainingSeconds ~/ 60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        (_remainingSeconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ===============================================================
  // OTP BERUBAH
  // ===============================================================

  void _onOtpChanged(
    String value,
    int index,
  ) {
    // ---------------------------------------------------------------
    // Jika user menghapus angka
    // ---------------------------------------------------------------

    if (value.isEmpty) {
      if (index > 0) {
        FocusScope.of(context).requestFocus(
          otpFocusNodes[index - 1],
        );
      }

      return;
    }

    // ---------------------------------------------------------------
    // Jika user mengetik angka
    // ---------------------------------------------------------------

    if (value.length > 1) {
      otpControllers[index].text =
          value.substring(value.length - 1);

      otpControllers[index].selection =
          TextSelection.fromPosition(
        TextPosition(
          offset:
              otpControllers[index].text.length,
        ),
      );
    }

    // ---------------------------------------------------------------
    // Pindah ke kotak berikutnya
    // ---------------------------------------------------------------

    if (index < 5) {
      FocusScope.of(context).requestFocus(
        otpFocusNodes[index + 1],
      );
    } else {
      FocusScope.of(context).unfocus();

      _checkOtp();
    }

    setState(() {});
  }

  // ===============================================================
  // CEK OTP
  // ===============================================================

    void _checkOtp() {
    final otp = otpControllers
        .map((controller) => controller.text)
        .join();

    if (otp.length < 6) {
        return;
    }

    // ===============================================================
    // PINDAH KE HALAMAN BUAT PASSWORD BARU
    // ===============================================================

    FocusScope.of(context).unfocus();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
        builder: (context) =>
            const NewPasswordScreen(),
        ),
    );
    }

  // ===============================================================
  // KIRIM ULANG OTP
  // ===============================================================

  void _resendOtp() {
    if (_remainingSeconds > 0) {
      return;
    }

    // Kosongkan semua OTP
    for (final controller in otpControllers) {
      controller.clear();
    }

    // Fokus kembali ke kotak pertama
    FocusScope.of(context).requestFocus(
      otpFocusNodes[0],
    );

    // Mulai timer kembali
    _startTimer();

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Kode verifikasi telah dikirim ulang.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFFB05039),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===============================================================
  // OTP INPUT
  // ===============================================================

  Widget _buildOtpField({
    required int index,
  }) {
    return SizedBox(
      width: 40,
      height: 48,

      child: TextField(
        controller: otpControllers[index],
        focusNode: otpFocusNodes[index],

        keyboardType: TextInputType.number,

        textAlign: TextAlign.center,

        maxLength: 1,

        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),

        onChanged: (value) {
          _onOtpChanged(
            value,
            index,
          );
        },

        decoration: InputDecoration(
          counterText: '',

          filled: true,

          fillColor:
              const Color(0xFFFFFCF9),

          contentPadding:
              EdgeInsets.zero,

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(13),

            borderSide:
                const BorderSide(
              color: Color(0xFFFF7775),
              width: 1,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(13),

            borderSide:
                const BorderSide(
              color: Color(0xFFB05039),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          child: Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal:
                  size.width * 0.09,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ===================================================
                // SPASI ATAS
                // ===================================================

                SizedBox(
                  height:
                      size.height * 0.095,
                ),

                // ===================================================
                // JUDUL
                // ===================================================

                Text(
                  'Kode Verifikasi',

                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize:
                        size.width * 0.060,
                    fontWeight:
                        FontWeight.bold,
                    color: brown,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                // ===================================================
                // DESKRIPSI
                // ===================================================

                Text(
                  'Kami telah mengirimkan kode verifikasi ke\n'
                  'email/ nomor HP anda.',

                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize:
                        size.width * 0.035,
                    height: 1.35,
                    color:
                        const Color(
                      0xFF5E5753,
                    ),
                  ),
                ),

                SizedBox(
                  height:
                      size.height * 0.050,
                ),

                // ===================================================
                // 6 KOTAK OTP
                // ===================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    for (int i = 0; i < 6; i++)
                      _buildOtpField(
                        index: i,
                      ),
                  ],
                ),

                // ===================================================
                // JARAK
                // ===================================================

                SizedBox(
                  height:
                      size.height * 0.055,
                ),

                // ===================================================
                // TIDAK MENERIMA KODE?
                // ===================================================

                Center(
                  child: Text(
                    'Tidak menerima kode?',

                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize:
                          size.width * 0.035,
                      color:
                          const Color(
                        0xFF5E5753,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                // ===================================================
                // KIRIM ULANG
                // ===================================================

                Center(
                  child: GestureDetector(
                    onTap: _resendOtp,

                    child: Text(
                      _remainingSeconds > 0
                          ? 'Kirim ulang ($_timerText)'
                          : 'Kirim ulang',

                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize:
                            size.width * 0.040,
                        fontWeight:
                            FontWeight.w700,
                        color: _remainingSeconds > 0
                            ? brown
                            : brown,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height:
                      size.height * 0.08,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller
        in otpControllers) {
      controller.dispose();
    }

    for (final focusNode
        in otpFocusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }
}