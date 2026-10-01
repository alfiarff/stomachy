import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const Color primaryBrown = Color(0xFFAA4E39);

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // WRAPPER TRANSPARAN
    //
    // Slot bottomNavigationBar memang selalu menempel di dasar
    // layar. Supaya kartunya terlihat "terbang", kartunya kita
    // beri margin di dalam wrapper yang transparan, sehingga
    // background halaman tetap terlihat di sekelilingnya.
    // =========================================================

    return Container(
      color: Colors.transparent,

      child: SafeArea(
        top: false,

        child: Container(
          // ================================================
          // MARGIN INI YANG MEMBUAT NAVIGASI "TERBANG"
          // ================================================

          margin: const EdgeInsets.fromLTRB(
            14,
            0,
            14,
            14,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            // 4 SUDUT SEMUA MEMBULAT (bukan cuma atas)
            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Beranda',
                ),

                _buildNavItem(
                  index: 1,
                  icon: Icons.health_and_safety_outlined,
                  activeIcon:
                      Icons.health_and_safety_rounded,
                  label: 'Skrining',
                ),

                _buildNavItem(
                  index: 2,
                  icon: Icons.medical_services_outlined,
                  activeIcon:
                      Icons.medical_services_rounded,
                  label: 'Dokter',
                ),

                _buildNavItem(
                  index: 3,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  label: 'Edukasi',
                ),

                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool active = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: () => onItemSelected(index),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,

          margin: const EdgeInsets.symmetric(
            horizontal: 2,
          ),

          height: 60,

          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFFFE5D8)
                : Colors.transparent,

            borderRadius: BorderRadius.circular(18),
          ),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  active ? activeIcon : icon,
                  key: ValueKey(active),
                  size: 26,
                  color: primaryBrown,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  color: primaryBrown,
                  fontWeight: active
                      ? FontWeight.w800
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}