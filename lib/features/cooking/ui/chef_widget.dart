import 'package:flutter/material.dart';

import '../engine/cooking_controller.dart';

class ChefWidget extends StatelessWidget {
  const ChefWidget({
    super.key,
    required this.message,
    required this.mood,
    required this.chefAsset,
  });

  final String message;
  final ChefMood mood;
  final String chefAsset;

  @override
  Widget build(BuildContext context) {
    final accent = switch (mood) {
      ChefMood.happy => const Color(0xFF5BCB8A),
      ChefMood.excited => const Color(0xFFFFB347),
      ChefMood.thinking => const Color(0xFF7EA8FF),
      ChefMood.proud => const Color(0xFFFF7B9C),
    };

    final moodLabel = switch (mood) {
      ChefMood.happy => 'Happy Chef',
      ChefMood.excited => 'Excited Chef',
      ChefMood.thinking => 'Thinking Chef',
      ChefMood.proud => 'Proud Chef',
    };

    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[
                  accent.withValues(alpha: 0.36),
                  accent.withValues(alpha: 0.14),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                chefAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.face_retouching_natural,
                    color: accent,
                    size: 46,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x2A000000),
                        blurRadius: 12,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        moodLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D3557),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: -8,
                  bottom: 16,
                  child: CustomPaint(
                    size: const Size(16, 16),
                    painter: _BubbleTailPainter(accent: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}
