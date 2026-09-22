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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                activeIcon: Icons.health_and_safety_rounded,
                label: 'Skrining',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.medical_services_outlined,
                activeIcon: Icons.medical_services_rounded,
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
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool active = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 62,
        height: 57,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFFFE5D8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 23,
              color: primaryBrown,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: primaryBrown,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}