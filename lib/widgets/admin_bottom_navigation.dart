import 'package:flutter/material.dart';

// ===============================================================
// BOTTOM NAVIGATION KHUSUS ADMIN
//
// Berbeda dengan navigasi user (5 menu), navigasi admin
// hanya 4 menu: Beranda, Artikel, Konten, Profil.
// Style tetap floating card yang sama dengan navigasi user.
// ===============================================================

class AdminBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const Color primaryBrown = Color(0xFFAA4E39);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,

      child: SafeArea(
        top: false,

        child: Container(
          margin: const EdgeInsets.fromLTRB(
            14,
            0,
            14,
            13,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
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
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Beranda',
                ),

                _buildNavItem(
                  index: 1,
                  icon: Icons.article_outlined,
                  activeIcon: Icons.article_rounded,
                  label: 'Artikel',
                ),

                _buildNavItem(
                  index: 2,
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: 'Konten',
                ),

                _buildNavItem(
                  index: 3,
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
                  fontSize: 12,
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