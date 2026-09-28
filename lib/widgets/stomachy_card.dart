import 'package:flutter/material.dart';

// ===============================================================
// STOMACHY CARD
//
// Kartu standar seluruh aplikasi STOMACHY.
// Gaya: drop shadow lembut, tanpa border.
//
// - useBorder: false -> shadow saja
// - useBorder: true  -> shadow + border krem tipis
// ===============================================================

class StomachyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double radius;
  final bool useBorder;
  final VoidCallback? onTap;

  const StomachyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color = const Color(0xFFFFFCF9),
    this.radius = 16,
    this.useBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: useBorder
            ? Border.all(
                color: const Color(0xFFF6E3D7),
                width: 1,
              )
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      );
    }

    return card;
  }
}