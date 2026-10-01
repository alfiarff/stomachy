import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';



import 'home_screen.dart';

import 'screening_screen.dart';

import 'doctor_screen.dart';

import 'edukasi_screen.dart';

import 'profile_screen.dart';

import 'consultation_chat_screen.dart';

import '../widgets/bottom_navigation.dart';



class ConsultationHistoryScreen extends StatefulWidget {

  const ConsultationHistoryScreen({super.key});



  @override

  State<ConsultationHistoryScreen> createState() =>

      _ConsultationHistoryScreenState();

}



class _ConsultationHistoryScreenState

    extends State<ConsultationHistoryScreen> {

  int _selectedIndex = 4;



  final Color backgroundColor = const Color(0xFFFFF5EF);

  final Color primaryBrown = const Color(0xFF5A392F);

  final Color borderBrown = const Color(0xFFFF806A);



  // ===============================================================

  // NAVIGATION

  // ===============================================================



  void _onNavigationTap(int index) {

    if (index == _selectedIndex) {

      return;

    }



    if (index == 0) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) => const HomeScreen(),

        ),

      );

      return;

    }



    if (index == 1) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) => const ScreeningScreen(),

        ),

      );

      return;

    }



    if (index == 2) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) => const DoctorScreen(),

        ),

      );

      return;

    }



    if (index == 3) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) => const EdukasiScreen(),

        ),

      );

      return;

    }



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

  // FIRESTORE STREAM

  // ===============================================================



  Stream<QuerySnapshot<Map<String, dynamic>>> _historyStream() {

    final User? currentUser =

        FirebaseAuth.instance.currentUser;



    if (currentUser == null) {

      return const Stream.empty();

    }



    return FirebaseFirestore.instance

        .collection('consultations')

        .where('userId', isEqualTo: currentUser.uid)

        .snapshots();

  }



  // ===============================================================

  // DATE FORMAT

  // ===============================================================



  String _formatDate(dynamic value) {

    if (value == null) {

      return '-';

    }



    DateTime? date;



    if (value is Timestamp) {

      date = value.toDate();

    } else if (value is DateTime) {

      date = value;

    }



    if (date == null) {

      return value.toString();

    }



    const List<String> months = [

      'Januari',

      'Februari',

      'Maret',

      'April',

      'Mei',

      'Juni',

      'Juli',

      'Agustus',

      'September',

      'Oktober',

      'November',

      'Desember',

    ];



    return '${date.day} ${months[date.month - 1]} ${date.year}';

  }



  String _getDate(Map<String, dynamic> data) {

    if (data['consultationDate'] != null) {

      return _formatDate(data['consultationDate']);

    }



    if (data['createdAt'] != null) {

      return _formatDate(data['createdAt']);

    }



    return '-';

  }



  String _formatDoctorName(String name) {
    final String trimmed = name.trim();
    if (trimmed.toLowerCase().startsWith('dr.')) return trimmed;
    return 'dr. $trimmed';
  }

  String _getStatus(Map<String, dynamic> data) {

    final String status =

        (data['status'] ?? '').toString().toLowerCase();



    if (status == 'completed' ||

        status == 'selesai' ||

        status == 'done') {

      return 'Selesai';

    }



    if (status == 'active') {

      return 'Aktif';

    }



    return data['status']?.toString() ?? 'Selesai';

  }



  Color _getStatusBackground(String status) {

    if (status == 'Aktif') {

      return const Color(0xFFFFE5D8);

    }



    return const Color(0xFFDFF3DD);

  }



  Color _getStatusTextColor(String status) {

    if (status == 'Aktif') {

      return const Color(0xFFAA4E39);

    }



    return const Color(0xFF188447);

  }



  // ===============================================================

  // BUILD

  // ===============================================================



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: backgroundColor,



      body: SafeArea(

        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

          stream: _historyStream(),

          builder: (context, snapshot) {

            if (snapshot.hasError) {

              return Column(

                children: [

                  _buildHeader(),

                  const Expanded(

                    child: Center(

                      child: Text(

                        'Gagal memuat riwayat konsultasi.',

                        style: TextStyle(

                          fontFamily: 'Nunito',

                          fontSize: 13,

                        ),

                      ),

                    ),

                  ),

                ],

              );

            }



            if (snapshot.connectionState ==

                ConnectionState.waiting) {

              return Column(

                children: [

                  _buildHeader(),

                  const Expanded(

                    child: Center(

                      child: CircularProgressIndicator(

                        color: Color(0xFFAA4E39),

                      ),

                    ),

                  ),

                ],

              );

            }



            final List<QueryDocumentSnapshot<Map<String, dynamic>>>

                documents = snapshot.data?.docs ?? [];



            documents.sort((a, b) {

              final dynamic aDate = a.data()['updatedAt'] ??

                  a.data()['createdAt'];



              final dynamic bDate = b.data()['updatedAt'] ??

                  b.data()['createdAt'];



              DateTime aTime = DateTime(2000);

              DateTime bTime = DateTime(2000);



              if (aDate is Timestamp) {

                aTime = aDate.toDate();

              }



              if (bDate is Timestamp) {

                bTime = bDate.toDate();

              }



              return bTime.compareTo(aTime);

            });



            return SingleChildScrollView(

              physics: const ClampingScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(

                22,

                12,

                22,

                105,

              ),

              child: Column(

                children: [

                  _buildHeader(),



                  const SizedBox(height: 20),



                  if (documents.isEmpty)

                    _buildEmptyState()

                  else

                    ...documents.map(

                      (document) {

                        final Map<String, dynamic> data =

                            document.data();



                        final ConsultationHistoryData history =

                            ConsultationHistoryData(

                          consultationId: document.id,

                          doctorName:

                              data['doctorName']?.toString() ??

                                  'Dokter',

                          specialty:

                              data['specialty']?.toString() ??

                                  'Dokter Umum',

                          date: _getDate(data),

                          time:

                              data['consultationTime']?.toString() ??

                                  '-',

                          doctorImage:

                              data['doctorImage']?.toString() ?? '',

                          status: _getStatus(data),

                        );



                        return Padding(

                          padding: const EdgeInsets.only(

                            bottom: 17,

                          ),

                          child:

                              _buildConsultationCard(history),

                        );

                      },

                    ),

                ],

              ),

            );

          },

        ),

      ),



      bottomNavigationBar: AppBottomNavigation(

        selectedIndex: _selectedIndex,

        onItemSelected: _onNavigationTap,

      ),

    );

  }



  // ===============================================================

  // EMPTY STATE

  // ===============================================================



  Widget _buildEmptyState() {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.symmetric(

        horizontal: 25,

        vertical: 40,

      ),

      child: Column(

        children: [

          Icon(

            Icons.chat_bubble_outline_rounded,

            size: 55,

            color: primaryBrown.withOpacity(0.35),

          ),



          const SizedBox(height: 15),



          Text(

            'Belum ada riwayat chat',

            style: TextStyle(

              fontFamily: 'Nunito',

              fontSize: 15,

              fontWeight: FontWeight.w700,

              color: primaryBrown,

            ),

          ),



          const SizedBox(height: 5),



          const Text(

            'Riwayat konsultasi kamu akan muncul di sini.',

            textAlign: TextAlign.center,

            style: TextStyle(

              fontFamily: 'Nunito',

              fontSize: 12,

              color: Color(0xFF77716E),

            ),

          ),

        ],

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

                alignment: Alignment.centerLeft,

                child: Icon(

                  Icons.arrow_back_rounded,

                  size: 29,

                  color: Colors.black,

                ),

              ),

            ),

          ),



          Expanded(

            child: Center(

              child: Text(

                'Riwayat Chat',

                style: TextStyle(

                  fontFamily: 'Fredoka',

                  fontSize: 22,

                  fontWeight: FontWeight.w700,

                  color: primaryBrown,

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

  // CONSULTATION CARD

  // ===============================================================



  Widget _buildConsultationCard(

    ConsultationHistoryData history,

  ) {

    return InkWell(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (context) => ConsultationChatScreen(

              consultationId: history.consultationId,

              doctorName: history.doctorName,

              specialty: history.specialty,

              doctorImage: history.doctorImage,

              selectedTime: history.time,

            ),

          ),

        );

      },

      borderRadius: BorderRadius.circular(18),

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(

          color: const Color(0xFFFFFCF9),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(

            color: borderBrown,

            width: 0.9,

          ),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(0.12),

              blurRadius: 5,

              offset: const Offset(0, 3),

            ),

          ],

        ),

        child: Row(

          children: [

            // FOTO DOKTER

            Container(

              width: 60,

              height: 60,

              decoration: const BoxDecoration(

                shape: BoxShape.circle,

                color: Color(0xFFEDE5DF),

              ),

              clipBehavior: Clip.antiAlias,

              child: history.doctorImage.isNotEmpty

                  ? Image.asset(

                      history.doctorImage,

                      fit: BoxFit.cover,

                      errorBuilder: (

                        context,

                        error,

                        stackTrace,

                      ) {

                        return const Icon(

                          Icons.person_rounded,

                          size: 38,

                          color: Color(0xFFB65339),

                        );

                      },

                    )

                  : const Icon(

                      Icons.person_rounded,

                      size: 38,

                      color: Color(0xFFB65339),

                    ),

            ),



            const SizedBox(width: 13),



            // DATA DOKTER

            Expanded(

              child: Column(

                crossAxisAlignment:

                    CrossAxisAlignment.start,

                children: [

                  Text(

                    history.doctorName,

                    style: TextStyle(

                      fontFamily: 'Nunito',

                      fontSize: 15,

                      fontWeight: FontWeight.w700,

                      color: primaryBrown,

                    ),

                  ),



                  const SizedBox(height: 3),



                  Text(

                    history.specialty,

                    style: const TextStyle(

                      fontFamily: 'Nunito',

                      fontSize: 12,

                      color: Colors.black,

                    ),

                  ),



                  const SizedBox(height: 5),



                  Text(

                    '${history.date} • ${history.time} WIB',

                    style: const TextStyle(

                      fontFamily: 'Nunito',

                      fontSize: 12,

                      color: Color(0xFF77716E),

                    ),

                  ),



                  const SizedBox(height: 5),



                  Container(

                    padding: const EdgeInsets.symmetric(

                      horizontal: 10,

                      vertical: 4,

                    ),

                    decoration: BoxDecoration(

                      color: _getStatusBackground(

                        history.status,

                      ),

                      borderRadius:

                          BorderRadius.circular(15),

                    ),

                    child: Text(

                      history.status,

                      style: TextStyle(

                        fontFamily: 'Nunito',

                        fontSize: 10,

                        fontWeight: FontWeight.w700,

                        color: _getStatusTextColor(

                          history.status,

                        ),

                      ),

                    ),

                  ),

                ],

              ),

            ),



            const Icon(

              Icons.chevron_right_rounded,

              size: 28,

              color: Colors.black,

            ),

          ],

        ),

      ),

    );

  }

}



// ===============================================================

// MODEL RIWAYAT KONSULTASI

// ===============================================================



class ConsultationHistoryData {

  final String consultationId;

  final String doctorName;

  final String specialty;

  final String date;

  final String time;

  final String doctorImage;

  final String status;



  ConsultationHistoryData({

    required this.consultationId,

    required this.doctorName,

    required this.specialty,

    required this.date,

    required this.time,

    required this.doctorImage,

    required this.status,

  });

}