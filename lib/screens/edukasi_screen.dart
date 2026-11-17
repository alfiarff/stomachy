
import 'package:flutter/material.dart';

import '../widgets/bottom_navigation.dart';

import 'home_screen.dart';
import 'screening_screen.dart';
import 'doctor_screen.dart';
import 'profile_screen.dart';
import 'pengetahuan_screen.dart';
import 'food_recommendation_screen.dart';
import 'sport_recommendation_screen.dart';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  int _selectedIndex = 3;

  final Color backgroundColor = const Color(0xFFFFF5EF);
  final Color primaryBrown = const Color(0xFF493028);
  final Color accentBrown = const Color(0xFFB9543A);

  void _onNavigationTap(int index) {
    if (index == _selectedIndex) return;

    Widget? destination;

    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;
      case 1:
        destination = const ScreeningScreen();
        break;
      case 2:
        destination = const DoctorScreen();
        break;
      case 4:
        destination = const ProfileScreen();
        break;
    }

    if (destination != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination!),
      );
    }
  }

  void _openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
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
              Navigator.maybePop(context);
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
          Expanded(
            child: Center(
              child: Text(
                'Edukasi',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: _buildHeader(),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                child: Column(
                  children: [
                    _buildMenuCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Pengetahuan GERD',
                      subtitle: 'Pelajari informasi dan pengetahuan seputar GERD.',
                      onTap: () {
                        _openPage(const PengetahuanScreen());
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildMenuCard(
                      icon: Icons.restaurant_rounded,
                      title: 'Rekomendasi Makanan',
                      subtitle: 'Temukan pilihan makanan yang baik untuk lambung.',
                      onTap: () {
                        _openPage(const FoodRecommendationScreen());
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildMenuCard(
                      icon: Icons.directions_run_rounded,
                      title: 'Rekomendasi Olahraga',
                      subtitle: 'Kenali pilihan olahraga yang sesuai untuk penderita GERD.',
                      onTap: () {
                        _openPage(const RecommendationSportScreen());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavigationTap,
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCFA),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9D9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: accentBrown,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF766D68),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right_rounded,
                size: 27,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
