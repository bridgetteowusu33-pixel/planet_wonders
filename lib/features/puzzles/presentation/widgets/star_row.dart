import 'package:flutter/material.dart';

class StarRow extends StatelessWidget {
  const StarRow({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 18,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final int stars;
  final int maxStars;
  final double size;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: List.generate(maxStars, (index) {
        final filled = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: filled ? const Color(0xFFFFC83D) : const Color(0xFFB0B8C4),
          ),
        );
      }),
    );
  }
}
