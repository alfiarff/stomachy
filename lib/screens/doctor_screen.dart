import 'dart:convert';



import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';



import 'home_screen.dart';

import 'screening_screen.dart';

import '../widgets/bottom_navigation.dart';

import '../widgets/stomachy_card.dart';

import 'edukasi_screen.dart';

import 'profile_screen.dart';

import 'doctor_detail_screen.dart';



class DoctorScreen extends StatefulWidget {

  const DoctorScreen({super.key});



  @override

  State<DoctorScreen> createState() => _DoctorScreenState();

}



class _DoctorScreenState extends State<DoctorScreen> {

  int _selectedIndex = 2;



  bool _showAvailableOnly = false;

  String _searchQuery = '';



  final Color backgroundColor = const Color(0xFFFFF5ED);

  final Color primaryBrown = const Color(0xFFB65339);

  final Color darkBrown = const Color(0xFF2F211D);

  final Color borderBrown = const Color(0xFFE76F51);



  // ================================================================

  // FIRESTORE

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _doctorStream;

  @override
  void initState() {
    super.initState();

    _doctorStream = FirebaseFirestore.instance
        .collection('users')
        .where(
          'role',
          isEqualTo: 'doctor',
        )
        .snapshots();
  }

  // ================================================================

  // FILTER DATA

  // ================================================================



  List<DoctorData> _filteredDoctors(

    List<DoctorData> doctors,

  ) {

    final String query =

        _searchQuery.trim().toLowerCase();



    return doctors.where((doctor) {

      final bool matchesSearch =

          doctor.name

                  .toLowerCase()

                  .contains(query) ||

              doctor.specialty

                  .toLowerCase()

                  .contains(query);



      final bool matchesAvailability =

          !_showAvailableOnly ||

              doctor.status

                      .toLowerCase() ==

                  'online';



      return matchesSearch &&

          matchesAvailability;

    }).toList();

  }



  // ================================================================

  // NAVIGATION

  // ================================================================



  void _onNavigationTap(int index) {

    if (index == 2) {

      return;

    }



    if (index == 0) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>

              const HomeScreen(),

        ),

      );

      return;

    }



    if (index == 1) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>

              const ScreeningScreen(),

        ),

      );

      return;

    }



    if (index == 3) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>

              const EdukasiScreen(),

        ),

      );

      return;

    }



    if (index == 4) {

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (context) =>

              const ProfileScreen(),

        ),

      );

    }

  }



  // ================================================================

  // BUKA DETAIL DOKTER

  // ================================================================



  void _openDoctorDetail(

    DoctorData doctor,

  ) {

    if (doctor.status

            .toLowerCase() !=

        'online') {

      return;

    }



    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>

            DoctorDetailScreen(

          doctor: doctor,

        ),

      ),

    );

  }



  // ================================================================

  // BUILD

  // ================================================================



  @override

  Widget build(

    BuildContext context,

  ) {

    return Scaffold(

      backgroundColor:

          backgroundColor,



      body: SafeArea(

        child: StreamBuilder<

            QuerySnapshot<

                Map<String, dynamic>>>(

          stream: _doctorStream,

          builder: (

            context,

            snapshot,

          ) {

            if (snapshot

                    .connectionState ==

                ConnectionState.waiting) {

              return const Center(

                child:

                    CircularProgressIndicator(

                  color:

                      Color(0xFFB65339),

                  strokeWidth: 2,

                ),

              );

            }



            if (snapshot.hasError) {

              return _buildErrorState(

                snapshot.error

                    .toString(),

              );

            }



            final List<

                    QueryDocumentSnapshot<

                        Map<String, dynamic>>>

                documents =

                snapshot.data?.docs ??

                    [];



            final List<DoctorData>

                doctors =

                documents.map(

              (document) {

                return DoctorData

                    .fromFirestore(

                  document.id,

                  document.data(),

                );

              },

            ).toList();



            final List<DoctorData>

                filteredDoctors =

                _filteredDoctors(

              doctors,

            );



            return SingleChildScrollView(

              physics:

                  const ClampingScrollPhysics(),

              padding:

                  const EdgeInsets.fromLTRB(

                14,

                10,

                14,

                90,

              ),

              child: Column(

                crossAxisAlignment:

                    CrossAxisAlignment.start,

                children: [

                  _buildHeader(),



                  const SizedBox(

                    height: 20,

                  ),



                  _buildSearchBar(),



                  const SizedBox(

                    height: 20,

                  ),



                  _buildFilterButtons(),



                  const SizedBox(

                    height: 20,

                  ),



                  if (filteredDoctors

                      .isEmpty)

                    _buildEmptyState()

                  else

                    ...filteredDoctors.map(

                      (doctor) =>

                          Padding(

                        padding:

                            const EdgeInsets

                                .only(

                          bottom: 20,

                        ),

                        child:

                            _buildDoctorCard(

                          doctor,

                        ),

                      ),

                    ),

                ],

              ),

            );

          },

        ),

      ),



      bottomNavigationBar:

          AppBottomNavigation(

        selectedIndex:

            _selectedIndex,

        onItemSelected:

            _onNavigationTap,

      ),

    );

  }



  // ================================================================

  // HEADER

  // ================================================================



  Widget _buildHeader() {

    return Row(

      children: [

        GestureDetector(

          onTap: () {

            Navigator.pop(

              context,

            );

          },

          behavior:

              HitTestBehavior.opaque,

          child: const SizedBox(

            width: 40,

            height: 40,

            child: Align(

              alignment:

                  Alignment.centerLeft,

              child: Icon(

                Icons

                    .arrow_back_ios_new_rounded,

                size: 25,

                color: Colors.black,

              ),

            ),

          ),

        ),



        Expanded(

          child: Center(

            child: Text(

              'Konsultasi Dokter',

              style:

                  const TextStyle(

                fontFamily:

                    'Fredoka',

                fontSize: 22,

                fontWeight:

                    FontWeight.w800,

                color:

                    Colors.black,

              ),

            ),

          ),

        ),



        const SizedBox(

          width: 40,

        ),

      ],

    );

  }



  // ================================================================

  // SEARCH BAR

  // ================================================================



  Widget _buildSearchBar() {

    return Container(

      height: 42,

      padding:

          const EdgeInsets.symmetric(

        horizontal: 15,

      ),

      decoration:

          BoxDecoration(

        color:

            const Color(0xFFFFFCFA),

        borderRadius:

            BorderRadius.circular(

          21,

        ),

        boxShadow: [

          BoxShadow(

            color: Colors.black

                .withOpacity(

              0.07,

            ),

            blurRadius: 6,

            offset:

                const Offset(0, 3),

          ),

        ],

      ),

      child: Row(

        crossAxisAlignment:

            CrossAxisAlignment.center,

        children: [

          const Icon(

            Icons.search_rounded,

            size: 19,

            color:

                Color(0xFFB65339),

          ),



          const SizedBox(

            width: 8,

          ),



          Expanded(

            child: TextField(

              onChanged: (

                value,

              ) {

                setState(() {

                  _searchQuery =

                      value;

                });

              },

              textAlignVertical:

                  TextAlignVertical

                      .center,

              style:

                  const TextStyle(

                fontFamily:

                    'Nunito',

                fontSize: 11,

                color:

                    Colors.black,

              ),

              decoration:

                  const InputDecoration(

                border:

                    InputBorder.none,

                enabledBorder:

                    InputBorder.none,

                focusedBorder:

                    InputBorder.none,

                disabledBorder:

                    InputBorder.none,

                isCollapsed:

                    true,

                hintText:

                    'Cari dokter atau spesialis',

                hintStyle:

                    TextStyle(

                  fontFamily:

                      'Nunito',

                  fontSize: 11,

                  color:

                      Color(0xFF8C8582),

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }



  // ================================================================

  // FILTER BUTTON

  // TANPA ANIMASI

  // TANPA RIPPLE

  // TANPA POP-UP

  // ================================================================



  Widget _buildFilterButtons() {

    return Row(

      children: [

        Expanded(

          child: _buildFilterButton(

            label: 'Semua',

            isActive:

                !_showAvailableOnly,

            onTap: () {

              if (_showAvailableOnly) {

                setState(() {

                  _showAvailableOnly =

                      false;

                });

              }

            },

          ),

        ),



        const SizedBox(

          width: 10,

        ),



        Expanded(

          child: _buildFilterButton(

            label:

                'Tersedia Hari Ini',

            isActive:

                _showAvailableOnly,

            onTap: () {

              if (!_showAvailableOnly) {

                setState(() {

                  _showAvailableOnly =

                      true;

                });

              }

            },

          ),

        ),

      ],

    );

  }



  Widget _buildFilterButton({

    required String label,

    required bool isActive,

    required VoidCallback onTap,

  }) {

    return GestureDetector(

      onTap: onTap,

      behavior:

          HitTestBehavior.opaque,

      child: Container(

        width:

            double.infinity,

        height: 38,

        alignment:

            Alignment.center,

        decoration:

            BoxDecoration(

          color: isActive

              ? primaryBrown

              : const Color(

                  0xFFFFFCFA,

                ),

          borderRadius:

              BorderRadius.circular(

            19,

          ),

          boxShadow: [

            BoxShadow(

              color: Colors.black

                  .withOpacity(

                0.07,

              ),

              blurRadius: 5,

              offset:

                  const Offset(

                0,

                2,

              ),

            ),

          ],

        ),

        child: Text(

          label,

          textAlign:

              TextAlign.center,

          maxLines: 1,

          overflow:

              TextOverflow.ellipsis,

          style: TextStyle(

            fontFamily:

                'Nunito',

            fontSize: 11,

            fontWeight:

                FontWeight.w700,

            color: isActive

                ? Colors.white

                : Colors.black,

          ),

        ),

      ),

    );

  }



  // ================================================================

  // DOCTOR CARD

  // ================================================================



  Widget _buildDoctorCard(

    DoctorData doctor,

  ) {

    final bool isOnline =

        doctor.status

                .toLowerCase() ==

            'online';



    return StomachyCard(

      color:

          const Color(0xFFFFFCF9),

      radius: 19,

      padding:

          const EdgeInsets.symmetric(

        horizontal: 15,

        vertical: 14,

      ),

      onTap: isOnline

          ? () {

              _openDoctorDetail(

                doctor,

              );

            }

          : null,

      child: Row(

        crossAxisAlignment:

            CrossAxisAlignment.center,

        children: [

          _buildDoctorImage(

            doctor,

          ),



          const SizedBox(

            width: 14,

          ),



          Expanded(

            child: Column(

              mainAxisSize:

                  MainAxisSize.min,

              crossAxisAlignment:

                  CrossAxisAlignment

                      .start,

              children: [

                Text(

                  doctor.name,

                  maxLines: 1,

                  overflow:

                      TextOverflow

                          .ellipsis,

                  style:

                      const TextStyle(

                    fontFamily:

                        'Nunito',

                    fontSize: 12,

                    fontWeight:

                        FontWeight.w700,

                    color:

                        Colors.black,

                  ),

                ),



                const SizedBox(

                  height: 5,

                ),



                Text(

                  doctor.specialty,

                  maxLines: 1,

                  overflow:

                      TextOverflow

                          .ellipsis,

                  style:

                      const TextStyle(

                    fontFamily:

                        'Nunito',

                    fontSize: 11,

                    fontWeight:

                        FontWeight.w400,

                    color:

                        Colors.black,

                  ),

                ),



                const SizedBox(

                  height: 5,

                ),



                Row(

                  mainAxisSize:

                      MainAxisSize.min,

                  children: [

                    Container(

                      width: 7,

                      height: 7,

                      decoration:

                          BoxDecoration(

                        color: isOnline

                            ? const Color(

                                0xFF18C85A,

                              )

                            : const Color(

                                0xFFFF3F3F,

                              ),

                        shape:

                            BoxShape

                                .circle,

                      ),

                    ),



                    const SizedBox(

                      width: 5,

                    ),



                    Text(

                      doctor.status,

                      style:

                          TextStyle(

                        fontFamily:

                            'Nunito',

                        fontSize: 11,

                        fontWeight:

                            FontWeight.w500,

                        color: isOnline

                            ? const Color(

                                0xFF18C85A,

                              )

                            : const Color(

                                0xFFFF3F3F,

                              ),

                      ),

                    ),

                  ],

                ),

              ],

            ),

          ),



          if (isOnline)

            const Padding(

              padding:

                  EdgeInsets.only(

                left: 8,

              ),

              child: Icon(

                Icons

                    .chevron_right_rounded,

                size: 22,

                color:

                    Color(0xFFB65339),

              ),

            ),

        ],

      ),

    );

  }



  // ================================================================

  // FOTO DOKTER

  // ================================================================



  Widget _buildDoctorImage(

    DoctorData doctor,

  ) {

    // Prioritas 1: Base64 dari Firestore

    if (doctor.photoBase64 !=

            null &&

        doctor.photoBase64!

            .isNotEmpty) {

      try {

        return Container(

          width: 56,

          height: 56,

          decoration:

              const BoxDecoration(

            shape:

                BoxShape.circle,

            color:

                Color(0xFFFFE3D1),

          ),

          clipBehavior:

              Clip.antiAlias,

          child: Image.memory(

            base64Decode(

              doctor.photoBase64!,

            ),

            fit: BoxFit.cover,

            errorBuilder:

                (

              context,

              error,

              stackTrace,

            ) {

              return _buildDefaultDoctorIcon();

            },

          ),

        );

      } catch (_) {

        return _buildDefaultDoctorIcon();

      }

    }



    // Prioritas 2: URL dari Firestore

    if (doctor.photoUrl !=

            null &&

        doctor.photoUrl!

            .isNotEmpty) {

      return Container(

        width: 56,

        height: 56,

        decoration:

            const BoxDecoration(

          shape:

              BoxShape.circle,

          color:

              Color(0xFFFFE3D1),

        ),

        clipBehavior:

            Clip.antiAlias,

        child: Image.network(

          doctor.photoUrl!,

          fit: BoxFit.cover,

          errorBuilder:

              (

            context,

            error,

            stackTrace,

          ) {

            return _buildDefaultDoctorIcon();

          },

        ),

      );

    }



    // Prioritas 3: field image

    if (doctor.image.isNotEmpty) {

      return Container(

        width: 56,

        height: 56,

        decoration:

            const BoxDecoration(

          shape:

              BoxShape.circle,

          color:

              Color(0xFFFFE3D1),

        ),

        clipBehavior:

            Clip.antiAlias,

        child: Image.asset(

          doctor.image,

          fit: BoxFit.cover,

          errorBuilder:

              (

            context,

            error,

            stackTrace,

          ) {

            return _buildDefaultDoctorIcon();

          },

        ),

      );

    }



    return _buildDefaultDoctorIcon();

  }



  Widget _buildDefaultDoctorIcon() {

    return Container(

      width: 56,

      height: 56,

      decoration:

          const BoxDecoration(

        shape:

            BoxShape.circle,

        color:

            Color(0xFFFFE3D1),

      ),

      child: const Center(

        child: Icon(

          Icons.person_rounded,

          size: 32,

          color:

              Color(0xFFB65339),

        ),

      ),

    );

  }



  // ================================================================

  // EMPTY STATE

  // ================================================================



  Widget _buildEmptyState() {

    return StomachyCard(

      color:

          const Color(0xFFFFFCF9),

      radius: 19,

      margin:

          const EdgeInsets.only(

        top: 10,

      ),

      padding:

          const EdgeInsets.symmetric(

        vertical: 30,

        horizontal: 20,

      ),

      child: Column(

        children: [

          Icon(

            Icons

                .search_off_rounded,

            size: 45,

            color:

                primaryBrown,

          ),



          const SizedBox(

            height: 12,

          ),



          const Text(

            'Dokter tidak ditemukan',

            style:

                TextStyle(

              fontFamily:

                  'Nunito',

              fontSize: 12,

              fontWeight:

                  FontWeight.w700,

              color:

                  Colors.black,

            ),

          ),



          const SizedBox(

            height: 6,

          ),



          const Text(

            'Coba cari dengan nama dokter atau spesialis.',

            textAlign:

                TextAlign.center,

            style:

                TextStyle(

              fontFamily:

                  'Nunito',

              fontSize: 11,

              color:

                  Colors.black,

            ),

          ),

        ],

      ),

    );

  }



  // ================================================================

  // ERROR STATE

  // ================================================================



  Widget _buildErrorState(

    String error,

  ) {

    return Center(

      child: Padding(

        padding:

            const EdgeInsets.all(

          24,

        ),

        child: Column(

          mainAxisAlignment:

              MainAxisAlignment

                  .center,

          children: [

            const Icon(

              Icons

                  .error_outline_rounded,

              size: 50,

              color:

                  Color(0xFFB65339),

            ),



            const SizedBox(

              height: 12,

            ),



            const Text(

              'Data dokter gagal dimuat',

              textAlign:

                  TextAlign.center,

              style:

                  TextStyle(

                fontFamily:

                    'Nunito',

                fontSize: 12,

                fontWeight:

                    FontWeight.w700,

                color:

                    Colors.black,

              ),

            ),



            const SizedBox(

              height: 6,

            ),



            Text(

              error,

              textAlign:

                  TextAlign.center,

              style:

                  const TextStyle(

                fontFamily:

                    'Nunito',

                fontSize: 10,

                color:

                    Color(0xFF8C8582),

              ),

            ),

          ],

        ),

      ),

    );

  }

}



// ================================================================

// MODEL DATA DOKTER

// ================================================================



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



          name:
        'dr. ${(data['name'] ??
                'Dokter')
            .toString()}',

      specialty:

          (data['specialization'] ??

                  data['specialty'] ??

                  'Dokter Umum')

              .toString(),



      status:

          (data['status'] ??

                  'Offline')

              .toString(),



      rating:

          (data['rating'] ??

                  '0.0')

              .toString(),



      reviews:

          (data['reviews'] ??

                  '0')

              .toString(),



      image:

          (data['image'] ??

                  '')

              .toString(),



      schedules:

          data['schedules'] is List

              ? List<String>.from(

                  (data['schedules']

                          as List)

                      .map(

                        (item) =>

                            item.toString(),

                      ),

                )

              : [],



      experience:

          (data['experience'] ??

                  '-')

              .toString(),



      education:

          (data['education'] ??

                  '-')

              .toString(),



      location:

          (data['location'] ??

                  '-')

              .toString(),



      photoBase64:

          data['photoBase64']

              ?.toString(),



      photoUrl:

          data['photoUrl']

              ?.toString(),

    );

  }

}