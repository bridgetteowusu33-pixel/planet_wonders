import 'package:flutter/material.dart';

/// Pot widget that reuses the cooking game's pot PNGs.
///
/// Switches face based on game state (idle, happy, surprised, party, worried).
class RushPotWidget extends StatelessWidget {
  const RushPotWidget({
    super.key,
    required this.countryId,
    required this.face,
    this.size = 120,
  });

  final String countryId;
  final String face;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = 'assets/cooking/v2/$countryId/pot/pot_$face.webp';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Image.asset(
        path,
        key: ValueKey<String>(face),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _emojiFallback(),
      ),
    );
  }

  Widget _emojiFallback() {
    final emoji = switch (face) {
      'happy' => '\u{1F604}',    // 😄
      'surprised' => '\u{1F62E}', // 😮
      'party' => '\u{1F973}',    // 🥳
      'worried' => '\u{1F61F}',  // 😟
      _ => '\u{1F60A}',          // 😊
    };
    return Container(
      key: ValueKey<String>('emoji_$face'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}
