import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/motion/motion_settings_provider.dart';
import '../../../core/theme/pw_theme.dart';

/// Static badge info for well-known badge IDs.
const _staticBadgeInfo =
    <String, ({String emoji, String title, String subtitle})>{
  'quiz_history_star': (
    emoji: '\u{2B50}',
    title: 'History Star',
    subtitle: 'You answered 3 quizzes!',
  ),
};

/// Resolve badge display info from a badge ID.
///
/// Supports both static IDs (`quiz_history_star`) and dynamic per-country
/// IDs (`quiz_explorer_ghana`, `quiz_master_usa`).
({String emoji, String title, String subtitle})? _resolveBadge(String id) {
  final staticMatch = _staticBadgeInfo[id];
  if (staticMatch != null) return staticMatch;

  // quiz_explorer_<countryId>
  if (id.startsWith('quiz_explorer_')) {
    final country = id.replaceFirst('quiz_explorer_', '');
    final name = country[0].toUpperCase() + country.substring(1);
    return (
      emoji: '\u{1F30D}',
      title: '$name Explorer',
      subtitle: 'You completed 3 $name quizzes!',
    );
  }

  // quiz_master_<countryId>
  if (id.startsWith('quiz_master_')) {
    final country = id.replaceFirst('quiz_master_', '');
    final name = country[0].toUpperCase() + country.substring(1);
    return (
      emoji: '\u{1F3C6}',
      title: '$name Quiz Master',
      subtitle: 'You completed ALL $name quizzes!',
    );
  }

  return null;
}

/// Shows a celebration popup when a quiz badge is unlocked.
Future<void> showQuizBadgePopup(
  BuildContext context,
  String badgeId,
) {
  final info = _resolveBadge(badgeId);
  if (info == null) return Future.value();

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Badge popup',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    pageBuilder: (_, _, _) => _BadgePopupContent(
      emoji: info.emoji,
      title: info.title,
      subtitle: info.subtitle,
    ),
  );
}

// ---------------------------------------------------------------------------
// Badge popup content
// ---------------------------------------------------------------------------

class _BadgePopupContent extends StatefulWidget {
  const _BadgePopupContent({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  State<_BadgePopupContent> createState() => _BadgePopupContentState();
}

class _BadgePopupContentState extends State<_BadgePopupContent>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _confettiCtrl;
  bool _reduceMotion = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Create controllers with default durations — updated in didChangeDependencies.
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _reduceMotion = MotionUtil.isReducedFromContext(context);

    if (_reduceMotion) {
      _scaleCtrl.duration = const Duration(milliseconds: 120);
    }
    _scaleCtrl.forward();

    if (!_reduceMotion) _confettiCtrl.repeat();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: _reduceMotion ? Curves.easeOut : Curves.elasticOut,
    );

    return Stack(
      children: [
        // Confetti backdrop
        if (!_reduceMotion)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(progress: _confettiCtrl.value),
                ),
              ),
            ),
          ),

        // Badge card
        Center(
          child: ScaleTransition(
            scale: scaleAnim,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: PWColors.navy.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: PWColors.navy,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: PWColors.navy.withValues(alpha: 0.6),
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: PWColors.coral,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        'Great Job!',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Confetti painter
// ---------------------------------------------------------------------------

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static const _colors = [
    PWColors.coral,
    PWColors.blue,
    PWColors.yellow,
    PWColors.mint,
    Color(0xFFAB47BC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const count = 48;

    for (var i = 0; i < count; i++) {
      final color = _colors[i % _colors.length];
      paint.color = color.withValues(alpha: 0.85);

      final x = (i * 0.618).remainder(1) * size.width;
      final y =
          ((progress * size.height * 1.3) + (i * 21)) % (size.height + 30) -
              15;
      final drift = math.sin((progress * math.pi * 2) + i) * 16;
      final rot = progress * math.pi * (i.isEven ? 1 : -1);
      final r = 3.0 + (i % 4);

      canvas.save();
      canvas.translate(x + drift, y);
      canvas.rotate(rot);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: r, height: r * 1.6), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
