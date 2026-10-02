import 'dart:convert';















import 'package:flutter/material.dart';







import 'package:firebase_auth/firebase_auth.dart';







import 'package:cloud_firestore/cloud_firestore.dart';















import '../../widgets/doctor_bottom_navigation.dart';















import 'doctorr_home_screen.dart';







import 'doctor_patients_screen.dart';







import 'doctor_chat_screen.dart';



import 'doctor_patient_chat_screen.dart';







import 'doctor_personal_information_screen.dart';







import 'doctor_schedule_screen.dart';















import '../about_stomachy_screen.dart';



import '../change_password_screen.dart';











import '../landing_screen.dart';















class DoctorProfileScreen extends StatefulWidget {







  const DoctorProfileScreen({super.key});















  @override







  State<DoctorProfileScreen> createState() =>







      _DoctorProfileScreenState();







}















class _DoctorProfileScreenState







    extends State<DoctorProfileScreen> {







  final int _selectedIndex = 3;















  final Color backgroundColor =







      const Color(0xFFFFF5EF);















  final Color primaryBrown =







      const Color(0xFF5A392F);















  final Color softOrange =







      const Color(0xFFFFE3D1);















  @override







  Widget build(BuildContext context) {







    return Scaffold(







      backgroundColor: backgroundColor,







      body: SafeArea(







        child: SingleChildScrollView(







          physics: const BouncingScrollPhysics(),







          padding: const EdgeInsets.fromLTRB(







            22,







            16,







            22,







            110,







          ),







          child: Column(







            children: [







              _buildProfileHeader(),















              const SizedBox(height: 18),















              _buildProfileMenuList(),















              const SizedBox(height: 43),



              _buildLogoutButton(),



              const SizedBox(height: 20),







            ],







          ),







        ),







      ),







      bottomNavigationBar: DoctorBottomNavigation(







        selectedIndex: _selectedIndex,







        onItemSelected: _onNavigationTap,







      ),







    );







  }















  // ===============================================================







  // BOTTOM NAVIGATION







  // ===============================================================















  void _onNavigationTap(int index) {







    if (index == _selectedIndex) {







      return;







    }















    if (index == 0) {







      Navigator.pushReplacement(







        context,







        MaterialPageRoute(







          builder: (context) =>







              const DoctorHomeScreen(),







        ),







      );







      return;







    }















    if (index == 1) {







      Navigator.pushReplacement(







        context,







        MaterialPageRoute(







          builder: (context) =>







              const DoctorPatientsScreen(),







        ),







      );







      return;







    }















    if (index == 2) {







      Navigator.pushReplacement(







        context,







        MaterialPageRoute(







          builder: (context) =>







              const DoctorChatScreen(),







        ),







      );







      return;







    }















    if (index == 3) {







      return;







    }







  }















  // ===============================================================







  // PROFILE HEADER







  // ===============================================================















  Widget _buildProfileHeader() {







    final User? user =







        FirebaseAuth.instance.currentUser;















    if (user == null) {







      return _buildProfileHeaderContent(







        name: 'Dokter',







        email: '',







        photoBase64: null,







        googlePhotoUrl: '',







      );







    }















    return StreamBuilder<DocumentSnapshot>(







      stream: FirebaseFirestore.instance







          .collection('users')







          .doc(user.uid)







          .snapshots(),







      builder: (context, snapshot) {







        String name =







            user.displayName ?? '';















        String email =







            user.email ?? '';















        String googlePhotoUrl =







            user.photoURL ?? '';















        String? photoBase64;















        if (googlePhotoUrl.startsWith('data:')) {







          googlePhotoUrl = '';







        }















        if (snapshot.hasData &&







            snapshot.data!.exists) {







          final dynamic rawData =







              snapshot.data!.data();















          if (rawData is Map<String, dynamic>) {







            final String? firestoreName =







                rawData['name']







                    ?.toString()







                    .trim();















            final String? firestoreEmail =







                rawData['email']







                    ?.toString()







                    .trim();















            final String? firestorePhoto =







                rawData['photoBase64']







                    ?.toString()







                    .trim();















            if (firestoreName != null &&







                firestoreName.isNotEmpty) {







              name = firestoreName;







            }















            if (firestoreEmail != null &&







                firestoreEmail.isNotEmpty) {







              email = firestoreEmail;







            }















            if (firestorePhoto != null &&







                firestorePhoto.isNotEmpty) {







              photoBase64 = firestorePhoto;







            }







          }







        }















        if (name.isEmpty) {







          name = 'Dokter';







        }















        if (!name.toLowerCase().startsWith('dr.')) {







          name = 'Dr. $name';







        }















        return _buildProfileHeaderContent(







          name: name,







          email: email,







          photoBase64: photoBase64,







          googlePhotoUrl: googlePhotoUrl,







        );







      },







    );







  }















  // ===============================================================







  // PROFILE HEADER CONTENT







  // ===============================================================















  Widget _buildProfileHeaderContent({







    required String name,







    required String email,







    required String? photoBase64,







    required String googlePhotoUrl,







  }) {







    return Container(







      width: double.infinity,







      decoration: BoxDecoration(







        color: const Color(0xFFFFFCF9),







        borderRadius: BorderRadius.circular(16),







        boxShadow: [







          BoxShadow(







            color: Colors.black.withOpacity(0.05),







            blurRadius: 6,







            offset: const Offset(0, 2),







          ),







        ],







      ),







      padding: const EdgeInsets.symmetric(







        horizontal: 15,







        vertical: 10,







      ),







      child: SizedBox(







        height: 64,







        child: Row(







          children: [







            Container(







              width: 58,







              height: 58,







              decoration: const BoxDecoration(







                shape: BoxShape.circle,







                color: Color(0xFFE8E8E8),







              ),







              child: ClipOval(







                child: _buildHeaderPhoto(







                  photoBase64: photoBase64,







                  googlePhotoUrl: googlePhotoUrl,







                ),







              ),







            ),















            const SizedBox(width: 14),















            Expanded(







              child: Column(







                mainAxisAlignment:







                    MainAxisAlignment.center,







                crossAxisAlignment:







                    CrossAxisAlignment.start,







                children: [







                  Text(







                    name,







                    maxLines: 1,







                    overflow:







                        TextOverflow.ellipsis,







                    style: const TextStyle(







                      fontFamily: 'Nunito',







                      fontSize: 12,







                      fontWeight:







                          FontWeight.w700,







                      color:







                          Color(0xFF30221E),







                    ),







                  ),















                  const SizedBox(height: 5),















                  Text(







                    email,







                    maxLines: 1,







                    overflow:







                        TextOverflow.ellipsis,







                    style: const TextStyle(







                      fontFamily: 'Nunito',







                      fontSize: 11,







                      color:







                          Color(0xFF493C37),







                    ),







                  ),







                ],







              ),







            ),







          ],







        ),







      ),







    );







  }















  // ===============================================================







  // GAMBAR FOTO HEADER







  // ===============================================================















  Widget _buildHeaderPhoto({







    required String? photoBase64,







    required String googlePhotoUrl,







  }) {







    if (photoBase64 != null &&







        photoBase64.isNotEmpty) {







      try {







        return Image.memory(







          base64Decode(photoBase64),







          fit: BoxFit.cover,







          errorBuilder: (







            context,







            error,







            stackTrace,







          ) {







            return const Icon(







              Icons.person,







              size: 38,







              color: Color(0xFF777777),







            );







          },







        );







      } catch (e) {







        return const Icon(







          Icons.person,







          size: 38,







          color: Color(0xFF777777),







        );







      }







    }















    if (googlePhotoUrl.isNotEmpty) {







      return Image.network(







        googlePhotoUrl,







        fit: BoxFit.cover,







        errorBuilder: (







          context,







          error,







          stackTrace,







        ) {







          return const Icon(







            Icons.person,







            size: 38,







            color: Color(0xFF777777),







          );







        },







      );







    }















    return const Icon(







      Icons.person,







      size: 38,







      color: Color(0xFF777777),







    );







  }















  // ===============================================================







  // MENU PROFILE







  // ===============================================================















  Widget _buildProfileMenuList() {



    return Column(



      children: [



        _buildProfileMenuCard(



          icon: Icons.person_outline_rounded,



          title: 'Informasi Pribadi',



          subtitle: 'Kelola informasi pribadi anda',



          onTap: () async {



            await Navigator.push(



              context,



              MaterialPageRoute(



                builder: (context) =>



                    const DoctorPersonalInformationScreen(),



              ),



            );



          },



        ),







        const SizedBox(height: 14),







        _buildProfileMenuCard(



          icon: Icons.calendar_month_outlined,



          title: 'Jadwal Dokter',



          subtitle: 'Atur jadwal praktik dokter',



          onTap: () {



            Navigator.push(



              context,



              MaterialPageRoute(



                builder: (context) =>



                    const DoctorScheduleScreen(),



              ),



            );



          },



        ),







        const SizedBox(height: 14),







        _buildProfileMenuCard(



          icon: Icons.history_rounded,



          title: 'Riwayat Chat',



          subtitle: 'Lihat riwayat chat pasien',



          onTap: () {



            Navigator.push(



              context,



              MaterialPageRoute(



                builder: (context) =>



                    const _DoctorChatHistoryScreen(),



              ),



            );



          },



        ),







        const SizedBox(height: 14),







        _buildProfileMenuCard(



          icon: Icons.lock_outline_rounded,



          title: 'Ubah Kata Sandi',



          subtitle: 'Ubah kata sandi akun anda',



          onTap: () {



            Navigator.push(



              context,



              MaterialPageRoute(



                builder: (context) =>



                    const ChangePasswordScreen(),



              ),



            );



          },



        ),







        const SizedBox(height: 14),







        _buildProfileMenuCard(



          icon: Icons.notifications_none_rounded,



          title: 'Notifikasi',



          subtitle: 'Kelola pemberitahuan aplikasi',



          onTap: () {



            Navigator.push(



              context,



              MaterialPageRoute(



                builder: (context) =>



                    const _DoctorNotificationScreen(),



              ),



            );



          },



        ),







        const SizedBox(height: 14),







        _buildProfileMenuCard(



          icon: Icons.info_outline_rounded,



          title: 'Tentang',



          subtitle: 'Informasi versi dan kebijakan aplikasi',



          onTap: () {



            Navigator.push(



              context,



              MaterialPageRoute(



                builder: (context) =>



                    const AboutStomachyScreen(),



              ),



            );



          },



        ),



      ],



    );



  }







  // PROFILE MENU CARD







  // ===============================================================















  Widget _buildProfileMenuCard({







    required IconData icon,







    required String title,







    required String subtitle,







    required VoidCallback onTap,







  }) {







    return Container(







      width: double.infinity,







      decoration: BoxDecoration(







        color: const Color(0xFFFFFCF9),







        borderRadius: BorderRadius.circular(16),







        boxShadow: [







          BoxShadow(







            color: Colors.black.withOpacity(0.05),







            blurRadius: 6,







            offset: const Offset(0, 2),







          ),







        ],







      ),







      padding: const EdgeInsets.symmetric(







        horizontal: 16,







        vertical: 10,







      ),







      child: InkWell(







        onTap: onTap,







        borderRadius: BorderRadius.circular(16),







        child: SizedBox(







          height: 50,







          child: Row(







            children: [







              Container(







                width: 35,







                height: 35,







                decoration: BoxDecoration(







                  color: softOrange,







                  borderRadius:







                      BorderRadius.circular(8),







                ),







                child: Icon(







                  icon,







                  size: 21,







                  color:







                      const Color(0xFF705044),







                ),







              ),















              const SizedBox(width: 12),















              Expanded(







                child: Column(







                  mainAxisAlignment:







                      MainAxisAlignment.center,







                  crossAxisAlignment:







                      CrossAxisAlignment.start,







                  children: [







                    Text(







                      title,







                      maxLines: 1,







                      overflow:







                          TextOverflow.ellipsis,







                      style: TextStyle(







                        fontFamily: 'Nunito',







                        fontSize: 12,







                        fontWeight:







                            FontWeight.w600,







                        color: primaryBrown,







                      ),







                    ),















                    const SizedBox(height: 3),















                    Text(







                      subtitle,







                      maxLines: 1,







                      overflow:







                          TextOverflow.ellipsis,







                      style: const TextStyle(







                        fontFamily: 'Nunito',







                        fontSize: 11,







                        color:







                            Color(0xFF776C67),







                      ),







                    ),







                  ],







                ),







              ),















              const SizedBox(width: 5),















              const Icon(







                Icons.chevron_right_rounded,







                size: 23,







                color: Color(0xFF222222),







              ),







            ],







          ),







        ),







      ),







    );







  }















  // ===============================================================







  // FEATURE MESSAGE







  // ===============================================================















  void _showFeatureMessage(







    String featureName,







  ) {







    ScaffoldMessenger.of(context)







      ..hideCurrentSnackBar()







      ..showSnackBar(







        SnackBar(







          content: Text(







            '$featureName belum tersedia.',







            style: const TextStyle(







              fontFamily: 'Nunito',







              fontSize: 12,







            ),







          ),







          backgroundColor:







              primaryBrown,







          behavior:







              SnackBarBehavior.floating,







          shape:







              RoundedRectangleBorder(







            borderRadius:







                BorderRadius.circular(12),







          ),







          margin:







              const EdgeInsets.all(18),







        ),







      );







  }















  // ===============================================================







  // LOGOUT BUTTON







  // ===============================================================















  Widget _buildLogoutButton() {







    return SizedBox(







      width: double.infinity,







      height: 53,







      child: OutlinedButton(







        onPressed: _showLogoutDialog,







        style: OutlinedButton.styleFrom(







          backgroundColor:







              const Color(0xFFFFEEE5),







          side: const BorderSide(







            color: Color(0xFFFF806A),







            width: 0.9,







          ),







          shape:







              RoundedRectangleBorder(







            borderRadius:







                BorderRadius.circular(17),







          ),







        ),







        child: Row(







          mainAxisAlignment:







              MainAxisAlignment.center,







          children: const [







            Icon(







              Icons.logout_rounded,







              size: 18,







              color:







                  Color(0xFFB9543A),







            ),







            SizedBox(width: 8),







            Text(







              'Keluar',







              style: TextStyle(







                fontFamily: 'Nunito',







                fontSize: 12,







                fontWeight:







                    FontWeight.w700,







                color:







                    Color(0xFFB9543A),







              ),







            ),







          ],







        ),







      ),







    );







  }















  // ===============================================================







  // LOGOUT DIALOG







  // ===============================================================















  void _showLogoutDialog() {







    showDialog(







      context: context,







      barrierDismissible: true,







      barrierColor:







          Colors.black.withOpacity(0.65),







      builder: (







        BuildContext dialogContext,







      ) {







        return Dialog(







          backgroundColor:







              Colors.transparent,







          elevation: 0,







          insetPadding:







              const EdgeInsets.symmetric(







            horizontal: 45,







          ),







          child: Container(







            width: double.infinity,







            padding:







                const EdgeInsets.fromLTRB(







              20,







              28,







              20,







              25,







            ),







            decoration: BoxDecoration(







              color: Colors.white,







              borderRadius:







                  BorderRadius.circular(18),







            ),







            child: Column(







              mainAxisSize:







                  MainAxisSize.min,







              children: [







                const Text(







                  'Konfirmasi Logout',







                  textAlign:







                      TextAlign.center,







                  style: TextStyle(







                    fontFamily: 'Nunito',







                    fontSize: 12,







                    fontWeight:







                        FontWeight.w700,







                    color:







                        Color(0xFFB9543A),







                  ),







                ),















                const SizedBox(height: 7),















                const Text(







                  'Apakah anda yakin ingin keluar dari sistem?',







                  textAlign:







                      TextAlign.center,







                  style: TextStyle(







                    fontFamily: 'Nunito',







                    fontSize: 11,







                    color:







                        Color(0xFF493C37),







                  ),







                ),















                const SizedBox(height: 16),















                Row(







                  children: [







                    Expanded(







                      child: SizedBox(







                        height: 30,







                        child:







                            OutlinedButton(







                          onPressed: () {







                            Navigator.pop(







                              dialogContext,







                            );







                          },







                          style:







                              OutlinedButton







                                  .styleFrom(







                            padding:







                                EdgeInsets.zero,







                            side:







                                const BorderSide(







                              color:







                                  Color(0xFFB9543A),







                              width: 0.8,







                            ),







                            shape:







                                RoundedRectangleBorder(







                              borderRadius:







                                  BorderRadius







                                      .circular(







                                7,







                              ),







                            ),







                          ),







                          child:







                              const Text(







                            'Batal',







                            style:







                                TextStyle(







                              fontFamily:







                                  'Nunito',







                              fontSize: 11,







                              fontWeight:







                                  FontWeight.w500,







                              color:







                                  Color(0xFFB9543A),







                            ),







                          ),







                        ),







                      ),







                    ),















                    const SizedBox(width: 10),















                    Expanded(







                      child: SizedBox(







                        height: 30,







                        child:







                            ElevatedButton(







                          onPressed: () async {







                            try {







                              await FirebaseAuth







                                  .instance







                                  .signOut();















                              if (!mounted ||







                                  !dialogContext







                                      .mounted) {







                                return;







                              }















                              Navigator.pop(







                                dialogContext,







                              );















                              Navigator







                                  .pushAndRemoveUntil(







                                context,







                                MaterialPageRoute(







                                  builder:







                                      (context) =>







                                          const LandingScreen(),







                                ),







                                (route) => false,







                              );







                            } catch (e) {







                              if (!dialogContext







                                  .mounted) {







                                return;







                              }















                              ScaffoldMessenger







                                  .of(context)







                                  .showSnackBar(







                                const SnackBar(







                                  content: Text(







                                    'Gagal keluar dari akun.',







                                    style:







                                        TextStyle(







                                      fontFamily:







                                          'Nunito',







                                      fontSize: 11,







                                    ),







                                  ),







                                  behavior:







                                      SnackBarBehavior







                                          .floating,







                                ),







                              );







                            }







                          },







                          style:







                              ElevatedButton







                                  .styleFrom(







                            backgroundColor:







                                const Color(







                              0xFFB9543A,







                            ),







                            foregroundColor:







                                Colors.white,







                            elevation: 0,







                            padding:







                                EdgeInsets.zero,







                            shape:







                                RoundedRectangleBorder(







                              borderRadius:







                                  BorderRadius







                                      .circular(







                                7,







                              ),







                            ),







                          ),







                          child:







                              const Text(







                            'Ya, Keluar',







                            style:







                                TextStyle(







                              fontFamily:







                                  'Nunito',







                              fontSize: 11,







                              fontWeight:







                                  FontWeight.w600,







                            ),







                          ),







                        ),







                      ),







                    ),







                  ],







                ),







              ],







            ),







          ),







        );







      },







    );







  }







}







// ===============================================================



// RIWAYAT CHAT DOKTER



// ===============================================================







class _DoctorChatHistoryScreen extends StatelessWidget {



  const _DoctorChatHistoryScreen();







  String _formatDate(dynamic value) {



    if (value is Timestamp) {



      final DateTime date = value.toDate();







      final String day = date.day.toString().padLeft(2, '0');



      final String month = date.month.toString().padLeft(2, '0');



      final String year = date.year.toString();



      final String hour = date.hour.toString().padLeft(2, '0');



      final String minute = date.minute.toString().padLeft(2, '0');







      return '$day/$month/$year • $hour:$minute';



    }







    return '-';



  }







  @override



  Widget build(BuildContext context) {



    final User? doctor = FirebaseAuth.instance.currentUser;







    if (doctor == null) {



      return const Scaffold(



        backgroundColor: Color(0xFFFFF5EF),



        body: Center(



          child: Text(



            'Akun dokter tidak ditemukan.',



            style: TextStyle(



              fontFamily: 'Nunito',



              fontSize: 12,



            ),



          ),



        ),



      );



    }







    return Scaffold(



      backgroundColor: const Color(0xFFFFF5EF),



      body: SafeArea(



        child: Column(



          children: [



            SizedBox(



              height: 58,



              child: Row(



                children: [



                  GestureDetector(



                    onTap: () => Navigator.pop(context),



                    child: const SizedBox(



                      width: 55,



                      height: 58,



                      child: Align(



                        alignment: Alignment.center,



                        child: Icon(



                          Icons.arrow_back_rounded,



                          size: 27,



                          color: Colors.black,



                        ),



                      ),



                    ),



                  ),



                  const Expanded(



                    child: Center(



                      child: Text(



                        'Riwayat Chat',



                        style: TextStyle(



                          fontFamily: 'Fredoka',



                          fontSize: 22,



                          fontWeight: FontWeight.w700,



                          color: Color(0xFF5A392F),



                        ),



                      ),



                    ),



                  ),



                  const SizedBox(width: 55),



                ],



              ),



            ),



            Expanded(



              child: StreamBuilder<



                  QuerySnapshot<Map<String, dynamic>>>(



                stream: FirebaseFirestore.instance



                    .collection('consultations')



                    .where('doctorId', isEqualTo: doctor.uid)



                    .snapshots(),



                builder: (context, snapshot) {



                  if (snapshot.connectionState ==



                      ConnectionState.waiting) {



                    return const Center(



                      child: CircularProgressIndicator(



                        color: Color(0xFFB65339),



                      ),



                    );



                  }







                  if (snapshot.hasError) {



                    return const Center(



                      child: Text(



                        'Riwayat chat gagal dimuat.',



                        style: TextStyle(



                          fontFamily: 'Nunito',



                          fontSize: 12,



                          color: Color(0xFF776C67),



                        ),



                      ),



                    );



                  }







                  final documents =



                      snapshot.data?.docs.toList() ?? [];







                  documents.sort((a, b) {



                    final dynamic aValue =



                        a.data()['updatedAt'] ??



                            a.data()['createdAt'];



                    final dynamic bValue =



                        b.data()['updatedAt'] ??



                            b.data()['createdAt'];







                    if (aValue is Timestamp &&



                        bValue is Timestamp) {



                      return bValue.compareTo(aValue);



                    }







                    return 0;



                  });







                  if (documents.isEmpty) {



                    return const Center(



                      child: Padding(



                        padding: EdgeInsets.all(30),



                        child: Column(



                          mainAxisSize: MainAxisSize.min,



                          children: [



                            Icon(



                              Icons.chat_bubble_outline_rounded,



                              size: 55,



                              color: Color(0xFFB65339),



                            ),



                            SizedBox(height: 14),



                            Text(



                              'Belum ada riwayat chat',



                              style: TextStyle(



                                fontFamily: 'Nunito',



                                fontSize: 15,



                                fontWeight: FontWeight.w700,



                                color: Color(0xFF5A392F),



                              ),



                            ),



                            SizedBox(height: 5),



                            Text(



                              'Riwayat chat pasien akan muncul di sini.',



                              textAlign: TextAlign.center,



                              style: TextStyle(



                                fontFamily: 'Nunito',



                                fontSize: 12,



                                color: Color(0xFF776C67),



                              ),



                            ),



                          ],



                        ),



                      ),



                    );



                  }







                  return ListView.separated(



                    padding: const EdgeInsets.fromLTRB(



                      22,



                      10,



                      22,



                      30,



                    ),



                    itemCount: documents.length,



                    separatorBuilder: (context, index) =>



                        const SizedBox(height: 12),



                    itemBuilder: (context, index) {



                      final document = documents[index];



                      final data = document.data();







                      final String patientName =



                          (data['userName'] ??



                                  data['name'] ??



                                  'Pasien')



                              .toString()



                              .trim();







                      final String lastMessage =



                          (data['lastMessage'] ?? '')



                              .toString()



                              .trim();







                      final String status =



                          (data['status'] ?? 'active').toString();







                      return GestureDetector(



                        onTap: () {



                          Navigator.push(



                            context,



                            MaterialPageRoute(



                              builder: (context) =>



                                  DoctorPatientChatScreen(



                                patient: {



                                  ...data,



                                  'consultationId':



                                      document.id,



                                },



                              ),



                            ),



                          );



                        },



                        child: Container(



                          width: double.infinity,



                          padding: const EdgeInsets.all(15),



                          decoration: BoxDecoration(



                            color: const Color(0xFFFFFCF9),



                            borderRadius: BorderRadius.circular(19),



                            boxShadow: [



                              BoxShadow(



                                color:



                                    Colors.black.withOpacity(0.05),



                                blurRadius: 6,



                                offset: const Offset(0, 2),



                              ),



                            ],



                          ),



                          child: Row(



                            children: [



                              Container(



                                width: 54,



                                height: 54,



                                decoration: const BoxDecoration(



                                  shape: BoxShape.circle,



                                  color: Color(0xFFE8E8E8),



                                ),



                                child: const Icon(



                                  Icons.person_rounded,



                                  size: 30,



                                  color: Color(0xFF777777),



                                ),



                              ),



                              const SizedBox(width: 13),



                              Expanded(



                                child: Column(



                                  crossAxisAlignment:



                                      CrossAxisAlignment.start,



                                  children: [



                                    Text(



                                      patientName.isEmpty



                                          ? 'Pasien'



                                          : patientName,



                                      maxLines: 1,



                                      overflow:



                                          TextOverflow.ellipsis,



                                      style: const TextStyle(



                                        fontFamily: 'Nunito',



                                        fontSize: 12,



                                        fontWeight: FontWeight.w700,



                                        color: Color(0xFF30221E),



                                      ),



                                    ),



                                    const SizedBox(height: 4),



                                    Text(



                                      lastMessage.isEmpty



                                          ? 'Belum ada pesan'



                                          : lastMessage,



                                      maxLines: 1,



                                      overflow:



                                          TextOverflow.ellipsis,



                                      style: const TextStyle(



                                        fontFamily: 'Nunito',



                                        fontSize: 11,



                                        color: Color(0xFF776C67),



                                      ),



                                    ),



                                    const SizedBox(height: 4),



                                    Text(



                                      '${_formatDate(data['updatedAt'] ?? data['createdAt'])} • $status',



                                      maxLines: 1,



                                      overflow:



                                          TextOverflow.ellipsis,



                                      style: const TextStyle(



                                        fontFamily: 'Nunito',



                                        fontSize: 10,



                                        color: Color(0xFF9A918C),



                                      ),



                                    ),



                                  ],



                                ),



                              ),



                              const SizedBox(width: 5),



                              const Icon(



                                Icons.chevron_right_rounded,



                                size: 23,



                                color: Colors.black,



                              ),



                            ],



                          ),



                        ),



                      );



                    },



                  );



                },



              ),



            ),



          ],



        ),



      ),



    );



  }



}







// ===============================================================



// NOTIFIKASI DOKTER



// ===============================================================







class _DoctorNotificationScreen extends StatefulWidget {



  const _DoctorNotificationScreen();







  @override



  State<_DoctorNotificationScreen> createState() =>



      _DoctorNotificationScreenState();



}







class _DoctorNotificationScreenState



    extends State<_DoctorNotificationScreen> {



  bool _chatNotification = true;



  bool _scheduleNotification = true;



  bool _loaded = false;







  Future<void> _loadSettings() async {



    if (_loaded) {



      return;



    }







    final User? user = FirebaseAuth.instance.currentUser;







    if (user == null) {



      return;



    }







    try {



      final snapshot = await FirebaseFirestore.instance



          .collection('users')



          .doc(user.uid)



          .get();







      final data = snapshot.data() ?? {};







      if (!mounted) {



        return;



      }







      setState(() {



        _chatNotification =



            data['chatNotification'] != false;



        _scheduleNotification =



            data['scheduleNotification'] != false;



        _loaded = true;



      });



    } catch (_) {



      if (mounted) {



        setState(() {



          _loaded = true;



        });



      }



    }



  }







  Future<void> _saveSetting(



    String field,



    bool value,



  ) async {



    final User? user = FirebaseAuth.instance.currentUser;







    if (user == null) {



      return;



    }







    try {



      await FirebaseFirestore.instance



          .collection('users')



          .doc(user.uid)



          .set(



        {field: value},



        SetOptions(merge: true),



      );



    } catch (_) {



      if (!mounted) {



        return;



      }







      ScaffoldMessenger.of(context).showSnackBar(



        const SnackBar(



          content: Text(



            'Pengaturan notifikasi gagal disimpan.',



            style: TextStyle(



              fontFamily: 'Nunito',



              fontSize: 11,



            ),



          ),



        ),



      );



    }



  }







  @override



  void initState() {



    super.initState();



    _loadSettings();



  }







  @override



  Widget build(BuildContext context) {



    return Scaffold(



      backgroundColor: const Color(0xFFFFF5EF),



      body: SafeArea(



        child: Padding(



          padding: const EdgeInsets.fromLTRB(



            22,



            12,



            22,



            30,



          ),



          child: Column(



            children: [



              SizedBox(



                height: 42,



                child: Row(



                  children: [



                    GestureDetector(



                      onTap: () => Navigator.pop(context),



                      child: const SizedBox(



                        width: 45,



                        height: 42,



                        child: Align(



                          alignment: Alignment.centerLeft,



                          child: Icon(



                            Icons.arrow_back_rounded,



                            size: 29,



                            color: Colors.black,



                          ),



                        ),



                      ),



                    ),



                    const Expanded(



                      child: Center(



                        child: Text(



                          'Notifikasi',



                          style: TextStyle(



                            fontFamily: 'Fredoka',



                            fontSize: 22,



                            fontWeight: FontWeight.w700,



                            color: Color(0xFF5A392F),



                          ),



                        ),



                      ),



                    ),



                    const SizedBox(width: 45),



                  ],



                ),



              ),



              const SizedBox(height: 22),



              _buildNotificationCard(



                icon: Icons.chat_bubble_outline_rounded,



                title: 'Notifikasi Chat',



                subtitle:



                    'Dapatkan pemberitahuan saat pasien mengirim chat.',



                value: _chatNotification,



                onChanged: (value) {



                  setState(() {



                    _chatNotification = value;



                  });



                  _saveSetting('chatNotification', value);



                },



              ),



              const SizedBox(height: 12),



              _buildNotificationCard(



                icon: Icons.calendar_month_outlined,



                title: 'Notifikasi Jadwal',



                subtitle:



                    'Dapatkan pengingat terkait jadwal dokter.',



                value: _scheduleNotification,



                onChanged: (value) {



                  setState(() {



                    _scheduleNotification = value;



                  });



                  _saveSetting(



                    'scheduleNotification',



                    value,



                  );



                },



              ),



            ],



          ),



        ),



      ),



    );



  }







  Widget _buildNotificationCard({



    required IconData icon,



    required String title,



    required String subtitle,



    required bool value,



    required ValueChanged<bool> onChanged,



  }) {



    return Container(



      width: double.infinity,



      padding: const EdgeInsets.symmetric(



        horizontal: 15,



        vertical: 12,



      ),



      decoration: BoxDecoration(



        color: const Color(0xFFFFFCF9),



        borderRadius: BorderRadius.circular(16),



        boxShadow: [



          BoxShadow(



            color: Colors.black.withOpacity(0.05),



            blurRadius: 6,



            offset: const Offset(0, 2),



          ),



        ],



      ),



      child: Row(



        children: [



          Container(



            width: 38,



            height: 38,



            decoration: BoxDecoration(



              color: const Color(0xFFFFE3D1),



              borderRadius: BorderRadius.circular(9),



            ),



            child: Icon(



              icon,



              size: 21,



              color: const Color(0xFF705044),



            ),



          ),



          const SizedBox(width: 12),



          Expanded(



            child: Column(



              crossAxisAlignment: CrossAxisAlignment.start,



              children: [



                Text(



                  title,



                  style: const TextStyle(



                    fontFamily: 'Nunito',



                    fontSize: 12,



                    fontWeight: FontWeight.w600,



                    color: Color(0xFF5A392F),



                  ),



                ),



                const SizedBox(height: 3),



                Text(



                  subtitle,



                  style: const TextStyle(



                    fontFamily: 'Nunito',



                    fontSize: 10.5,



                    color: Color(0xFF776C67),



                  ),



                ),



              ],



            ),



          ),



Switch(



  value: value,



  onChanged: onChanged,



  thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {



    if (states.contains(MaterialState.selected)) {



      return Colors.white;



    }







    return const Color(0xFFB8B0AC);



  }),



  trackColor: MaterialStateProperty.resolveWith<Color?>((states) {



    if (states.contains(MaterialState.selected)) {



      return const Color(0xFFB9543A);



    }







    return const Color(0xFFE5DDD8);



  }),



  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,



  thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {



    return null;



  }),



),



        ],



      ),



    );



  }



}




