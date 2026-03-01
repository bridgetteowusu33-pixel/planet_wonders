import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mood variants for the chef character avatar.
enum ChefAvatarMood { happy, excited, proud, thinking }

/// Renders an illustrated chef character with bobbing animation,
/// falling back to a coloured emoji circle when the asset is missing.
class ChefAvatar extends StatefulWidget {
  const ChefAvatar({
    super.key,
    required this.countryId,
    this.size = 64,
    this.mood = ChefAvatarMood.happy,
    this.enableBob = true,
  });

  final String countryId;
  final double size;
  final ChefAvatarMood mood;
  final bool enableBob;

  @override
  State<ChefAvatar> createState() => _ChefAvatarState();
}

class _ChefAvatarState extends State<ChefAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) return;
      if (widget.enableBob) _bob.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetPath(widget.countryId, widget.mood);

    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        final dy = math.sin(_bob.value * math.pi) * 3;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            path,
            width: widget.size,
            height: widget.size,
            cacheWidth: (widget.size * 2).toInt(),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _EmojiCircle(
              countryId: widget.countryId,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }

  static String _assetPath(String countryId, ChefAvatarMood mood) {
    final character = _characterNameFor(countryId);
    return 'assets/cooking/v2/$countryId/$character/${character}_${mood.name}.webp';
  }

  static String _characterNameFor(String countryId) {
    return switch (countryId.trim().toLowerCase()) {
      'ghana' => 'afia',
      'nigeria' => 'adetutu',
      'uk' || 'united_kingdom' => 'twins',
      'usa' || 'united_states' => 'ava',
      _ => 'chef',
    };
  }
}

class _EmojiCircle extends StatelessWidget {
  const _EmojiCircle({required this.countryId, required this.size});

  final String countryId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (emoji, color) = _charEmojiAndColor(countryId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }

  static (String, Color) _charEmojiAndColor(String countryId) {
    return switch (countryId.trim().toLowerCase()) {
      'ghana' => ('\u{1F469}\u{200D}\u{1F373}', const Color(0xFFFFCC80)),
      'nigeria' => ('\u{1F469}\u{200D}\u{1F373}', const Color(0xFFA5D6A7)),
      'uk' || 'united_kingdom' => ('\u{1F9D1}\u{200D}\u{1F373}', const Color(0xFF90CAF9)),
      'usa' || 'united_states' => ('\u{1F469}\u{200D}\u{1F373}', const Color(0xFFEF9A9A)),
      _ => ('\u{1F468}\u{200D}\u{1F373}', const Color(0xFFE0E0E0)),
    };
  }
}
